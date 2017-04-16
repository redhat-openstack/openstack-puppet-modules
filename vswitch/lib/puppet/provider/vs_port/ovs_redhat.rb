require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppetx', 'redhat', 'ifcfg.rb'))

BASE = '/etc/sysconfig/network-scripts/ifcfg-'

# When not seedling from interface file
DEFAULT = {
  'ONBOOT'        => 'yes',
  'BOOTPROTO'     => 'dhcp',
  'PEERDNS'       => 'no',
  'NM_CONTROLLED' => 'no',
  'NOZEROCONF'    => 'yes' }

Puppet::Type.type(:vs_port).provide(:ovs_redhat, :parent => :ovs) do
  desc 'Openvswitch port manipulation for RedHat OSes family'

  confine    :osfamily => :redhat
  defaultfor :osfamily => :redhat

  commands :ip     => 'ip'
  commands :ifdown => 'ifdown'
  commands :ifup   => 'ifup'
  commands :vsctl  => 'ovs-vsctl'

  def create
    unless vsctl('list-ports',
      @resource[:bridge]).include? @resource[:interface]
      super
    end

    if interface_physical?
      template = DEFAULT
      extras   = nil

      if link?
        extras = dynamic_default if dynamic?
        if File.exist?(BASE + @resource[:interface])
          template = from_str(File.read(BASE + @resource[:interface]))
        end
      end

      port = IFCFG::Port.new(@resource[:interface], @resource[:bridge])
      port.save(BASE + @resource[:interface])

      bridge = IFCFG::Bridge.new(@resource[:bridge], template)
      bridge.set(extras) if extras
      bridge.save(BASE + @resource[:bridge])

      ifdown(@resource[:bridge])
      ifdown(@resource[:interface])
      ifup(@resource[:interface])
      ifup(@resource[:bridge])
    end
  end

  def exists?
    if interface_physical?
      super &&
      IFCFG::OVS.exists?(@resource[:interface]) &&
      IFCFG::OVS.exists?(@resource[:bridge])
    else
      super
    end
  end

  def destroy
    if interface_physical?
      ifdown(@resource[:bridge])
      ifdown(@resource[:interface])
      IFCFG::OVS.remove(@resource[:interface])
      IFCFG::OVS.remove(@resource[:bridge])
    end
    super
  end

  private

  def dynamic?
    device = ''
    device = ip('addr', 'show', @resource[:interface])
    return device =~ /dynamic/ ? true : false
  end

  def link?
    if File.read("/sys/class/net/#{@resource[:interface]}/operstate") =~ /up/
      return true
    else
      return false
    end
  rescue Errno::ENOENT
    return false
  end

  def dynamic_default
    list = { 'OVSDHCPINTERFACES' => @resource[:interface] }
    # Persistent MAC address taken from interface
    bridge_mac_address = File.read("/sys/class/net/#{@resource[:interface]}/address").chomp
    if bridge_mac_address != ''
      list.merge!({ 'OVS_EXTRA' =>
        "\"set bridge #{@resource[:bridge]} other-config:hwaddr=#{bridge_mac_address}\"" })
    end
    list
  end

  def interface_physical?
    # OVS ports don't have entries in /sys/class/net
    # Alias interfaces (ethX:Y) must use ethX entries
    interface = @resource[:interface].sub(/:\d/, '')
    ! Dir["/sys/class/net/#{interface}"].empty?
  end

  def from_str(data)
    items = {}
    data.each_line do |line|
      if m = line.match(/^(.*)=(.*)$/)
        items.merge!(m[1] => m[2])
      end
    end
    items
  end
end
