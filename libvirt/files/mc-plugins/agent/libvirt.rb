require 'libvirt'
require 'xmlsimple'

module MCollective
  module Agent
    # An agent that interacts with libvirt.
    #
    # See http://github.com/puppetlabs/puppetlabs-libvirt/
    #
    # Released under the terms of ASL 2.0, same as Puppet
    class Libvirt<RPC::Agent
      metadata  :name    => "SimpleRPC Libvirt Agent",
                :description => "Agent to interact with libvirt",
                :author    => "Ken Barber",
                :license   => "ASLv2",
                :version   => "0.0.1",
                :url     => "http://github.com/puppetlabs/puppetlabs-libvirt/",
                :timeout   => 60

      # This is a convenience wrapper around opening and closing the connection to
      # libvirt.
      def libvirt_transaction(uri = "qemu:///system")
        conn = ::Libvirt::open(uri)

        yield conn

        conn.close
      end

      # This action returns a short list of domains for each hypervisor.
      action "domain_list" do
        begin
          Log.instance.debug("Getting domain_detail for libvirt")

          libvirt_transaction do |conn|
            domains = conn.list_domains
  
            reply["domain_list"] ||= {}
            domains.each do |id|
              domain = conn.lookup_domain_by_id(id)
              reply["domain_list"][domain.uuid] = {
                "name" => domain.name,
                "id" => domain.id,
                "num_vcpus" => domain.info.nr_virt_cpu || 0,
                "memory" => domain.info.memory || 0,
                "state" => domain.info.state,
              }
            end
          end

          reply["status"] = "ok"
        rescue Exception => e
          reply.fail "#{e}"
        end
      end

      # This action returns detailed information gathered from
      # libvirt for a particulur domain.
      action "domain_detail" do
        validate :uuid, String
        uuid = request[:uuid]

        begin
          Log.instance.debug("Getting domain_detail for libvirt")

          libvirt_transaction do |conn|
            domain = conn.lookup_domain_by_uuid(uuid)
  
            # Grab XML data and turn it into a hash
            xml_desc = XmlSimple.xml_in(domain.xml_desc, {})
  
            # The interface for information is a bit 
            # haphazard, so I'm cherrypicking to populate
            # this hash.
            reply["domain_detail"] = {
              "uuid" => uuid,
              "cpu_time" => domain.info.cpu_time,
              "state" => domain.info.state,
              "os_type" => domain.os_type,
              "xml_desc" => xml_desc,
            }
          end
        rescue Exception => e
          reply.fail "#{e}"
        end
      end

      action "domain_shutdown" do
        validate :uuid, String
        uuid = request[:uuid]

        begin
          Log.instance.debug("Doing shutdown_domain for libvirt")

          libvirt_transaction do |conn|
            domain = conn.lookup_domain_by_uuid(uuid)
            domain.shutdown
          end

          reply["status"] = ["ok",uuid.to_s]
        rescue Exception => e
          reply.fail "#{e}"
        end
         
      end

      # Destroy a domain
      action "domain_destroy" do
        validate :uuid, String
        uuid = request[:uuid]

        begin
          Log.instance.debug("Doing domain_destroy for libvirt")

          libvirt_transaction do |conn|
            domain = conn.lookup_domain_by_uuid(uuid)
            domain.destroy
          end

          reply["status"] = ["ok",uuid.to_s]
        rescue Exception => e
          reply.fail "#{e}"
        end
         
      end

      # This action attempts to start a domain that exists.
      action "domain_start" do
        validate :uuid, String
        uuid = request[:uuid]

        begin
          Log.instance.debug("Doing domain_start for libvirt")

          libvirt_transaction do |conn|
            domain = conn.lookup_domain_by_uuid(uuid)
            domain.start
          end

          reply["status"] = ["ok", uuid.to_s]
        rescue Exception => e
          reply.fail "#{e}"
        end
         
      end

      # This action creates a domain.
      action "domain_create" do
        validate :name, String
        name = request[:name]

        # start by creating a disk
        # TODO: this is very much inserted just to make this 'work' for now
        `qemu-img create -f qcow2 /srv/virt/virtuals/#{name}.img.disk.0 10000000000`

        # TODO: most basic way to create a template obviously.
        xml_template = <<-EOS
<domain type='kvm'>
  <name>#{name}</name>
  <memory>256000</memory>
  <vcpu>1</vcpu>
  <os>
    <type arch='x86_64'>hvm</type>
    <boot dev='hd'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <pae/>
  </features>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <devices>
    <emulator>/usr/bin/kvm</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/srv/virt/virtuals/#{name}.img.disk.0'/>
      <target dev='vda' bus='virtio'/>
      <alias name='virtio-disk0'/>
    </disk>
    <controller type='ide' index='0'>
      <alias name='ide0'/>
    </controller>
    <interface type='bridge'>
      <source bridge='virbr1'/>
      <model type='virtio'/>
      <alias name='net0'/>
    </interface>
    <serial type='pty'>
      <target port='0'/>
      <alias name='serial0'/>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
      <alias name='serial0'/>
    </console>
    <input type='mouse' bus='ps2'/>
    <graphics type='vnc' autoport='yes' listen='0.0.0.0'/>
    <video>
      <model type='cirrus' vram='9216' heads='1'/>
      <alias name='video0'/>
    </video>
    <memballoon model='virtio'>
      <alias name='balloon0'/>
    </memballoon>
  </devices>
</domain>
EOS

        begin
          Log.instance.debug("Doing list_nodedevices for libvirt")

          libvirt_transaction do |conn|
            domain = conn.define_domain_xml(xml_template)
            domain.create
          end

          reply["status"] = "ok"
        rescue Exception => e
          reply.fail "#{e}: #{e.libvirt_message}"
        end

      end

    end
  end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
