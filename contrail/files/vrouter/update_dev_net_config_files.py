# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

import argparse
import platform
import os
import socket
import netifaces
import netaddr
import subprocess
import struct
import tempfile
import xml.etree.ElementTree as ET
import commands
import re

def find_gateway(dev):
    gateway = ''
    cmd = "netstat -rn | grep ^\"0.0.0.0\" | grep %s | awk '{ print $2 }'" % \
        dev
    gateway = subprocess.check_output(cmd, shell=True).strip()
    return gateway
# end find_gateway


def get_dns_servers(dev):
    cmd = "grep \"^nameserver\\>\" /etc/resolv.conf | awk  '{print $2}'"
    dns_list = subprocess.check_output(cmd, shell=True)
    return dns_list.split()
# end get_dns_servers


def get_domain_search_list():
    domain_list = ''
    cmd = "grep ^\"search\" /etc/resolv.conf | awk '{$1=\"\";print $0}'"
    domain_list = subprocess.check_output(cmd, shell=True).strip()
    if not domain_list:
        cmd = "grep ^\"domain\" /etc/resolv.conf | awk '{$1=\"\"; print $0}'"
        domain_list = subprocess.check_output(cmd, shell=True).strip()
    return domain_list


def get_if_mtu(dev):
    cmd = "ifconfig %s | grep mtu | awk '{ print $NF }'" % dev
    mtu = subprocess.check_output(cmd, shell=True).strip()
    if not mtu:
        # for debian
        cmd = "ifconfig %s | grep MTU | sed 's/.*MTU.\([0-9]\+\).*/\1/g'" % dev
        mtu = subprocess.check_output(cmd, shell=True).strip()
    if mtu and mtu != '1500':
        return mtu
    return ''
# end if_mtu


def get_secondary_device(primary):
    for i in netifaces.interfaces ():
        try:
            if i == 'pkt1':
                continue
            if i == primary:
                continue
            if i == 'vhost0':
                continue
            if not netifaces.ifaddresses (i).has_key (netifaces.AF_INET):
                return i
        except ValueError,e:
                print "Skipping interface %s" % i
    raise RuntimeError, '%s not configured, rerun w/ --physical_interface' % ip


def get_device_by_ip(ip):
    for i in netifaces.interfaces():
        try:
            if i == 'pkt1':
                continue
            if netifaces.AF_INET in netifaces.ifaddresses(i):
                if ip == netifaces.ifaddresses(i)[netifaces.AF_INET][0][
                        'addr']:
                    if i == 'vhost0':
                        print "vhost0 is already present!"
                    return i
        except ValueError, e:
            print "Skipping interface %s" % i
    raise RuntimeError('%s not configured, rerun w/ --physical_interface' % ip)
# end get_device_by_ip


def rewrite_ifcfg_file(temp_dir_name, filename, dev, prsv_cfg):
    bond = False
    mac = ''

    if os.path.isdir('/sys/class/net/%s/bonding' % dev):
        bond = True
    # end if os.path.isdir...

    mac = netifaces.ifaddresses(dev)[netifaces.AF_LINK][0]['addr']
    ifcfg_file = '/etc/sysconfig/network-scripts/ifcfg-%s' % (dev)
    if not os.path.isfile(ifcfg_file):
        ifcfg_file = temp_dir_name + '/ifcfg-' + dev
        with open(ifcfg_file, 'w') as f:
            f.write('''#Contrail %s
TYPE=Ethernet
ONBOOT=yes
DEVICE="%s"
USERCTL=yes
NM_CONTROLLED=no
HWADDR=%s
''' % (dev, dev, mac))
            for dcfg in prsv_cfg:
                f.write(dcfg + '\n')
            f.flush()
    fd = open(ifcfg_file)
    f_lines = fd.readlines()
    fd.close()
    new_f_lines = []
    remove_items = ['IPADDR', 'NETMASK', 'PREFIX', 'GATEWAY', 'HWADDR',
                    'DNS1', 'DNS2', 'BOOTPROTO', 'NM_CONTROLLED', '#Contrail']

    remove_items.append('DEVICE')
    new_f_lines.append('#Contrail %s\n' % dev)
    new_f_lines.append('DEVICE=%s\n' % dev)

    for line in f_lines:
        found = False
        for text in remove_items:
            if text in line:
                found = True
        if not found:
            new_f_lines.append(line)

    new_f_lines.append('NM_CONTROLLED=no\n')
    if bond:
        new_f_lines.append('SUBCHANNELS=1,2,3\n')
    else:
        new_f_lines.append('HWADDR=%s\n' % mac)

    fdw = open(filename, 'w')
    fdw.writelines(new_f_lines)
    fdw.close()
# end rewrite_ifcfg_file


def migrate_routes(device):
    '''
    Sample output of /proc/net/route :
    Iface   Destination     Gateway         Flags   RefCnt  Use     Metric \
    Mask            MTU     Window  IRTT
    p4p1    00000000        FED8CC0A        0003    0       0       0      \
    00000000        0       0       0
    '''
    with open('/etc/sysconfig/network-scripts/route-vhost0',
              'w') as route_cfg_file:
        for route in open('/proc/net/route', 'r').readlines():
            if route.startswith(device):
                route_fields = route.split()
                destination = int(route_fields[1], 16)
                gateway = int(route_fields[2], 16)
                flags = int(route_fields[3], 16)
                mask = int(route_fields[7], 16)
                if flags & 0x2:
                    if destination != 0:
                        route_cfg_file.write(
                            socket.inet_ntoa(struct.pack('I', destination)))
                        route_cfg_file.write(
                            '/' + str(bin(mask).count('1')) + ' ')
                        route_cfg_file.write('via ')
                        route_cfg_file.write(
                            socket.inet_ntoa(struct.pack('I', gateway)) + ' ')
                        route_cfg_file.write('dev vhost0')
                    # end if detination...
                # end if flags &...
            # end if route.startswith...
        # end for route...
    # end with open...
# end def migrate_routes

def _rewrite_net_interfaces_file(temp_dir_name, dev, mac, vhost_ip, netmask, gateway_ip,
							host_non_mgmt_ip):

    result,status = commands.getstatusoutput('grep \"iface vhost0\" /etc/network/interfaces')
    if status == 0 :
        print "Interface vhost0 is already present in /etc/network/interfaces"
        print "Skipping rewrite of this file"
        return
    #endif

    vlan = False
    if os.path.isfile ('/proc/net/vlan/%s' % dev):
        vlan_info = open('/proc/net/vlan/config').readlines()
        match  = re.search('^%s.*\|\s+(\S+)$'%dev, "\n".join(vlan_info), flags=re.M|re.I)
        if not match:
            raise RuntimeError, 'Configured vlan %s is not found in /proc/net/vlan/config'%dev
        phydev = match.group(1)
        vlan = True

    # Replace strings matching dev to vhost0 in ifup and ifdown parts file
    # Any changes to the file/logic with static routes has to be
    # reflected in setup-vnc-static-routes.py too
    ifup_parts_file = os.path.join(os.path.sep, 'etc', 'network', 'if-up.d', 'routes')
    ifdown_parts_file = os.path.join(os.path.sep, 'etc', 'network', 'if-down.d', 'routes')

    if os.path.isfile(ifup_parts_file) and os.path.isfile(ifdown_parts_file):
        commands.getstatusoutput("sudo sed -i 's/%s/vhost0/g' %s" %(dev, ifup_parts_file))
        commands.getstatusoutput("sudo sed -i 's/%s/vhost0/g' %s" %(dev, ifdown_parts_file))

    temp_intf_file = '%s/interfaces' %(temp_dir_name)
    commands.getstatusoutput("cp /etc/network/interfaces %s" %(temp_intf_file))
    with open('/etc/network/interfaces', 'r') as fd:
        cfg_file = fd.read()

    if not host_non_mgmt_ip:
        # remove entry from auto <dev> to auto excluding these pattern
        # then delete specifically auto <dev>
        commands.getstatusoutput("sed -i '/auto %s/,/auto/{/auto/!d}' %s" %(dev, temp_intf_file))
        commands.getstatusoutput("sed -i '/auto %s/d' %s" %(dev, temp_intf_file))
        # add manual entry for dev
        commands.getstatusoutput("echo 'auto %s' >> %s" %(dev, temp_intf_file))
        commands.getstatusoutput("echo 'iface %s inet manual' >> %s" %(dev, temp_intf_file))
        commands.getstatusoutput("echo '    pre-up ifconfig %s up' >> %s" %(dev, temp_intf_file))
        commands.getstatusoutput("echo '    post-down ifconfig %s down' >> %s" %(dev, temp_intf_file))
        if vlan:
            commands.getstatusoutput("echo '    vlan-raw-device %s' >> %s" %(phydev, temp_intf_file))
        if 'bond' in dev.lower():
            iters = re.finditer('^\s*auto\s', cfg_file, re.M)
            indices = [match.start() for match in iters]
            matches = map(cfg_file.__getslice__, indices, indices[1:] + [len(cfg_file)])
            for each in matches:
                each = each.strip()
                if re.match('^auto\s+%s'%dev, each):
                    string = ''
                    for lines in each.splitlines():
                        if 'bond-' in lines:
                            string += lines+os.linesep
                    commands.getstatusoutput("echo '%s' >> %s" %(string, temp_intf_file))
                else:
                    continue
        commands.getstatusoutput("echo '' >> %s" %(temp_intf_file))
    else:
        #remove ip address and gateway
        commands.getstatusoutput("sed -i '/iface %s inet static/, +2d' %s" % (dev, temp_intf_file))
        commands.getstatusoutput("sed -i '/auto %s/ a\iface %s inet manual\\n    pre-up ifconfig %s up\\n    post-down ifconfig %s down\' %s"% (dev, dev, dev, dev, temp_intf_file))

    # populte vhost0 as static
    commands.getstatusoutput("echo '' >> %s" %(temp_intf_file))
    commands.getstatusoutput("echo 'auto vhost0' >> %s" %(temp_intf_file))
    commands.getstatusoutput("echo 'iface vhost0 inet static' >> %s" %(temp_intf_file))
    commands.getstatusoutput("echo '    pre-up %s/if-vhost0' >> %s" %('/opt/contrail/bin', temp_intf_file))
    commands.getstatusoutput("echo '    netmask %s' >> %s" %(netmask, temp_intf_file))
    commands.getstatusoutput("echo '    network_name application' >> %s" %(temp_intf_file))
    if vhost_ip:
        commands.getstatusoutput("echo '    address %s' >> %s" %(vhost_ip, temp_intf_file))
    if (not host_non_mgmt_ip) and gateway_ip:
        commands.getstatusoutput("echo '    gateway %s' >> %s" %(gateway_ip, temp_intf_file))
    elif not host_non_mgmt_ip:
        local_gw = find_gateway(dev)
        commands.getstatusoutput("echo '    gateway %s' >> %s" %(local_gw, temp_intf_file))


    domain = get_domain_search_list()
    if domain:
        commands.getstatusoutput("echo '    dns-search %s' >> %s" %(domain, temp_intf_file))
    dns_list = get_dns_servers(dev)
    if dns_list:
        commands.getstatusoutput("echo -n '    dns-nameservers' >> %s" %(temp_intf_file))
        for dns in dns_list:
            commands.getstatusoutput("echo -n ' %s' >> %s" %(dns, temp_intf_file))
    commands.getstatusoutput("echo '\n' >> %s" %(temp_intf_file))

    # move it to right place
    commands.getstatusoutput("sudo mv -f %s /etc/network/interfaces" %(temp_intf_file))

    #end _rewrite_net_interfaces_file

def update_dev_net_config_files(
    vhost_ip, multi_net, dev, compute_dev, netmask,
    gateway, cidr, host_non_mgmt_ip, macaddr):
    dist = platform.dist()[0]

    temp_dir_name = tempfile.mkdtemp()
    # make ifcfg-vhost0
    if dist.lower() == 'centos' or dist.lower() == 'fedora' or dist.lower() == 'redhat':
        with open('%s/ifcfg-vhost0' % temp_dir_name, 'w') as f:
            f.write('''#Contrail vhost0
DEVICE=vhost0
ONBOOT=yes
BOOTPROTO=none
IPV6INIT=no
USERCTL=yes
IPADDR=%s
NETMASK=%s
NM_CONTROLLED=no
#NETWORK MANAGER BUG WORKAROUND
SUBCHANNELS=1,2,3
''' % (vhost_ip, netmask))
            # Don't set gateway and DNS on vhost0 if on non-mgmt network
            if not multi_net:
                if gateway:
                    f.write('GATEWAY=%s\n' % (gateway))
                dns_list = get_dns_servers(dev)
                for i, dns in enumerate(dns_list):
                    f.write('DNS%d=%s\n' % (i + 1, dns))
                domain_list = get_domain_search_list()
                if domain_list:
                    f.write('DOMAIN="%s"\n' % domain_list)

            prsv_cfg = []
            mtu = get_if_mtu(dev)
            if mtu:
                dcfg = 'MTU=%s' % str(mtu)
                f.write(dcfg + '\n')
                prsv_cfg.append(dcfg)
            f.flush()
        cmd = "mv %s/ifcfg-vhost0 /etc/sysconfig/" \
            "network-scripts/ifcfg-vhost0" % (
                temp_dir_name)
        subprocess.call(cmd, shell=True)
        # make ifcfg-$dev
        if not os.path.isfile(
                '/etc/sysconfig/network-scripts/ifcfg-%s.rpmsave' % dev):
            cmd = "cp /etc/sysconfig/network-scripts/ifcfg-%s \
               /etc/sysconfig/network-scripts/ifcfg-%s.rpmsave" % (dev, dev)
            subprocess.call(cmd, shell=True)
        rewrite_ifcfg_file(temp_dir_name, '%s/ifcfg-%s' %
                           (temp_dir_name, dev), dev, prsv_cfg)

        if multi_net:
            migrate_routes(dev)
        cmd = "mv -f %s/ifcfg-%s /etc/contrail/" % (temp_dir_name, dev)
        subprocess.call(cmd, shell=True)
        cmd = "cp -f /etc/contrail/ifcfg-%s" \
        	" /etc/sysconfig/network-scripts" % (dev)
        subprocess.call(cmd, shell=True)
    # end if "centos" or "fedora" or "redhat"
    if ((dist.lower() == "ubuntu") or
        (dist.lower() == "debian")):
        _rewrite_net_interfaces_file(temp_dir_name, dev, macaddr,
                                        vhost_ip, netmask, gateway, host_non_mgmt_ip)
# end update_dev_net_config_files

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--vhost_ip", help="IP address for vhost interface")
    parser.add_argument(
        "--multi_net",
        help="flag to state if multi_net is configured",
        action="store_true")
    parser.add_argument("--dev", help="device or interface name")
    parser.add_argument("--compute_dev", help="compute device or interface name")
    parser.add_argument("--netmask",
                        help="netmask value")
    parser.add_argument("--gateway",
                        help="gateway value")
    parser.add_argument("--cidr",
                        help="cidr value")
    parser.add_argument("--host_non_mgmt_ip",
                        help="host data ip address")
    parser.add_argument("--mac",
                        help="mac address of the interface",
                        default="")
    args = parser.parse_args()
    update_dev_net_config_files(args.vhost_ip, args.multi_net,
                                args.dev, args.compute_dev,
                                args.netmask, args.gateway,
                                args.cidr, args.host_non_mgmt_ip, args.mac)
# end main

if __name__ == "__main__":
    import cgitb
    cgitb.enable(format='text')
    main()
# end if __name__
