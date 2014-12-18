#!/usr/bin/python
import shutil, tempfile, os, optparse, logging, sys

usage = "usage: %prog [options]"
parser = optparse.OptionParser(usage=usage)
parser.add_option("-i", "--isofile", help="ISO image", dest="isoimg")
parser.add_option("-d", "--domainid", help="Domain id ", dest="domainid")
parser.add_option("-n", "--vsmname", help="VSM name", dest="vsmname")
parser.add_option("-m", "--mgmtip", help="Management Ip address", dest="mgmtip")
parser.add_option("-s", "--mgmtsubnet", help="Management Subnet", dest="mgmtsubnet")
parser.add_option("-g", "--gateway", help="Management gateway", dest="mgmtgateway")
parser.add_option("-p", "--password", help="Admin account password", dest="adminpasswd")
parser.add_option("-r", "--vsmrole", help="VSM Role, primary ,secondary or standalone", dest="vsmrole")
parser.add_option("-f", "--file", help="Repackaged file", dest="repackediso")
(options, args) = parser.parse_args()

isoimg = options.isoimg
domainid = int(options.domainid)
vsmname = options.vsmname
mgmtip = options.mgmtip
mgmtsubnet = options.mgmtsubnet
mgmtgateway = options.mgmtgateway
adminpasswd = options.adminpasswd
vsmrole = options.vsmrole
repackediso = options.repackediso


class Command(object):
   """Run a command and capture it's output string, error string and exit status"""
   def __init__(self, command):
       self.command = command

   def run(self, shell=True):
       import subprocess as sp
       process = sp.Popen(self.command, shell = shell, stdout = sp.PIPE, stderr = sp.PIPE)
       self.pid = process.pid
       self.output, self.error = process.communicate()
       self.failed = process.returncode
       return self

   @property
   def returncode(self):
       return self.failed

def createOvfEnvXmlFile(domain, gateway, hostname, ip, subnet, password, vsm_mode):
        #TODO: write a proper xml
        ovf_f = tempfile.NamedTemporaryFile(delete=False)

        st = '<?xml version="1.0" encoding="UTF-8"?> \n'
        st += '<Environment \n'
        st += 'xmlns="http://schemas.dmtf.org/ovf/environment/1" \n'
        st += 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" \n'
        st += 'xmlns:oe="http://schemas.dmtf.org/ovf/environment/1" \n'
        st += 'xmlns:ve="http://www.vmware.com/schema/ovfenv" \n'
        st += 'oe:id=""> \n'
        st += '<PlatformSection> \n'
        st += '<Kind>VMware ESXi</Kind> \n'
        st += '<Version>4.0.0</Version> \n'
        st += '<Vendor>VMware, Inc.</Vendor> \n'
        st += '<Locale>en</Locale> \n'
        st += '</PlatformSection> \n'
        st += '<PropertySection> \n'
        st += '<Property oe:key="DomainId" oe:value="%s" /> \n' % (domain)
        st += '<Property oe:key="EnableTelnet" oe:value="True" /> \n'
        st += '<Property oe:key="GatewayIpV4" oe:value="%s" /> \n' % (gateway)
        st += '<Property oe:key="HostName" oe:value="%s" /> \n' % (hostname)
        st += '<Property oe:key="ManagementIpV4" oe:value="%s" /> \n' % (ip)
        st += '<Property oe:key="ManagementIpV4Subnet" oe:value="%s" /> \n' % (subnet)
        st += '<Property oe:key="OvfDeployment" oe:value="installer" /> \n'
        st += '<Property oe:key="SvsMode" oe:value="L3" /> \n'
        st += '<Property oe:key="Password" oe:value="%s" /> \n' % (password)
        st += '<Property oe:key="HARole" oe:value="%s" /> \n' % (vsm_mode)
        st += '<Property oe:key="EnableOpenStack" oe:value="True" /> \n'
        st += '<Property oe:key="SaveBootVars" oe:value="True" /> \n'
        #if vsm_mode == "primary":
        #    st += '<Property oe:key="HARole" oe:value="%s" /> \n' % (vsm_mode)
        #else:
        #   st += '<Property oe:key="HARole" oe:value="standalone" /> \n'
        st += '</PropertySection> \n'
        st += '</Environment> \n'

        ovf_f.write(st)
        ovf_f.close()
        return ovf_f

def main():
    """ repackages the iso file, with modified ovf file """

    #logger = logging.getLogger('myapp')
    #hdlr = logging.FileHandler('/tmp/myapp.log')
    #formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
    #hdlr.setFormatter(formatter)
    #logger.addHandler(hdlr) 
    #logger.setLevel(logging.DEBUG)

    ovf_f = createOvfEnvXmlFile(domain=domainid, gateway=mgmtgateway, hostname=vsmname, ip=mgmtip, subnet=mgmtsubnet, password=adminpasswd, vsm_mode=vsmrole)

    mntdir = tempfile.mkdtemp()
    ddir = tempfile.mkdtemp()

    cret = Command('/bin/mount -o loop -t iso9660 %s %s' % (isoimg, mntdir)).run()
    #logger.info("%s %s" % (cret.output, cret.error))
    if cret.failed: 
        print(sys.argv[0], "Error: Unable to mount disk ", cret.output, cret.error)
        sys.exit(1)
    cret = Command('/bin/cp -r %s/* %s' % (mntdir, ddir)).run()
    print(sys.argv[0], "Copying files ", cret.output, "X", cret.error,"X")
    if cret.failed: 
        print(sys.argv[0], "Error: Unable to copy files ", cret.output, cret.error)
        sys.exit(1)
    #logger.info("%s %s" % (cret.output, cret.error))

    cret = Command('/bin/umount %s' % (mntdir)).run()
    if cret.failed: 
        print(sys.argv[0], "Error: Unable to unmont dir ", cret.output, cret.error)
        sys.exit(1)
    #logger.info("%s %s" % (cret.output, cret.error))

    cret = Command('/bin/cp %s %s/ovf-env.xml' % (ovf_f.name, ddir)).run()
    if cret.failed:
        print(sys.argv[0], "Error: Unable to copy ovf file ", cret.output, cret.error)
        sys.exit(1)
    #logger.info("%s %s" % (cret.output, cret.error))


    if os.path.exists('%s/isolinux/isolinux.bin' % (ddir)):
        cret = Command('cd %s; /usr/bin/mkisofs -uid 0 -gid 0 -J -R -A Cisco_Nexus_1000V_VSM -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -o %s .' % (ddir, repackediso)).run()
        if cret.failed: 
            print(sys.argv[0],"Error: Unable to create isofs ", cret.output, cret.error)
            sys.exit(1)
        #logger.info("%s %s" % (cret.output, cret.error))
    else:
        cret = Command('cd %s; /usr/bin/mkisofs -uid 0 -gid 0 -J -R -A Cisco_Nexus_1000V_VSM -b boot/grub/iso9660_stage1_5 -no-emul-boot -boot-load-size 4 -boot-info-table -o %s .' % (ddir, repackediso)).run()
        if cret.failed: 
            print(sys.argv[0], "Error: Unable to create isofs grub ", cret.output, cret.error)
            sys.exit(1)
        #logger.info("%s %s" % (cret.output, cret.error))

    os.unlink(ovf_f.name)
    shutil.rmtree(mntdir)
    shutil.rmtree(ddir)

if __name__ == "__main__":
    main()

