require 'csv'
require 'json'
require 'puppet/util/inifile'

class Puppet::Provider::Neutron < Puppet::Provider

  def self.conf_filename
    '/etc/neutron/neutron.conf'
  end

  def self.withenv(hash, &block)
    saved = ENV.to_hash
    hash.each do |name, val|
      ENV[name.to_s] = val
    end

    yield
  ensure
    ENV.clear
    saved.each do |name, val|
      ENV[name] = val
    end
  end

  def self.neutron_credentials
    @neutron_credentials ||= get_neutron_credentials
  end

  def self.get_neutron_credentials
    auth_keys = ['admin_tenant_name', 'admin_user', 'admin_password']
    deprecated_auth_url = ['auth_host', 'auth_port', 'auth_protocol']
    conf = neutron_conf
    if conf and conf['keystone_authtoken'] and
        auth_keys.all?{|k| !conf['keystone_authtoken'][k].nil?} and
        ( deprecated_auth_url.all?{|k| !conf['keystone_authtoken'][k].nil?} or
        !conf['keystone_authtoken']['auth_uri'].nil? )
      creds = Hash[ auth_keys.map \
                   { |k| [k, conf['keystone_authtoken'][k].strip] } ]
      if !conf['keystone_authtoken']['auth_uri'].nil?
        creds['auth_uri'] = conf['keystone_authtoken']['auth_uri']
      else
        q = conf['keystone_authtoken']
        creds['auth_uri'] = "#{q['auth_protocol']}://#{q['auth_host']}:#{q['auth_port']}/v2.0/"
      end
      if conf['DEFAULT'] and !conf['DEFAULT']['nova_region_name'].nil?
        creds['nova_region_name'] = conf['DEFAULT']['nova_region_name'].strip
      end
      return creds
    else
      raise(Puppet::Error, "File: #{conf_filename} does not contain all \
required sections.  Neutron types will not work if neutron is not \
correctly configured.")
    end
  end

  def neutron_credentials
    self.class.neutron_credentials
  end

  def self.auth_endpoint
    @auth_endpoint ||= get_auth_endpoint
  end

  def self.get_auth_endpoint
    q = neutron_credentials
    if q['auth_uri'].nil?
      return "#{q['auth_protocol']}://#{q['auth_host']}:#{q['auth_port']}/v2.0/"
    else
      return "#{q['auth_uri']}".strip
    end
  end

  def self.neutron_conf
    return @neutron_conf if @neutron_conf
    @neutron_conf = Puppet::Util::IniConfig::File.new
    @neutron_conf.read(conf_filename)
    @neutron_conf
  end

  def self.auth_neutron(*args)
    q = neutron_credentials
    authenv = {
      :OS_AUTH_URL    => self.auth_endpoint,
      :OS_USERNAME    => q['admin_user'],
      :OS_TENANT_NAME => q['admin_tenant_name'],
      :OS_PASSWORD    => q['admin_password']
    }
    if q.key?('nova_region_name')
      authenv[:OS_REGION_NAME] = q['nova_region_name']
    end
    rv = nil
    timeout = 10
    end_time = Time.now.to_i + timeout
    loop do
      begin
        withenv authenv do
          rv = neutron(args)
        end
        break
      rescue Puppet::ExecutionFailure => e
        if ! e.message =~ /(\(HTTP\s+400\))|
              (400-\{\'message\'\:\s+\'\'\})|
              (\[Errno 111\]\s+Connection\s+refused)|
              (503\s+Service\s+Unavailable)|
              (504\s+Gateway\s+Time-out)|
              (\:\s+Maximum\s+attempts\s+reached)|
              (Unauthorized\:\s+bad\s+credentials)|
              (Max\s+retries\s+exceeded)/
          raise(e)
        end
        current_time = Time.now.to_i
        if current_time > end_time
          break
        else
          wait = end_time - current_time
          notice("Unable to complete neutron request due to non-fatal error: \"#{e.message}\". Retrying for #{wait} sec.")
        end
        sleep(2)
        # Note(xarses): Don't remove, we know that there is one of the
        # Recoverable erros above, So we will retry a few more times
      end
    end
    return rv
  end

  def auth_neutron(*args)
    self.class.auth_neutron(args)
  end

  def self.reset
    @neutron_conf        = nil
    @neutron_credentials = nil
  end

  def self.find_and_parse_json(text)
    # separate json from any possible garbage around it and parse
    rv = []
    if text.is_a? String
      text = text.split("\n")
    elsif !text.is_a? Array
      return rv
    end
    found = false
    (0..text.size-1).reverse_each do |line_no|
      if text[line_no] =~ /\]\s*$/
        end_of_json_line_no = line_no
        (0..end_of_json_line_no).reverse_each do |start_of_json_line_no|
          if text[start_of_json_line_no] =~ /^\s*\[/
            begin
              js_txt = text[start_of_json_line_no..end_of_json_line_no].join('')
              rv = JSON.parse(js_txt)
              found = true
            rescue
              # do nothing, next iteration please, because found==false
            end
          end
          break if found
        end
      end
      break if found
    end
    rv
  end

  def self.list_neutron_resources(type)
    ids = []
    list = auth_neutron("#{type}-list", '--format=json',
                        '--column=id')
    if list.nil?
      raise(Puppet::ExecutionFailure, "Can't retrieve #{type}-list because Neutron or Keystone API is not available.")
    end

    self.find_and_parse_json(list).each do |line|
      ids << line['id']
    end

    return ids
  end

  def self.get_neutron_resource_attrs(type, id)
    attrs = {}
    net = auth_neutron("#{type}-show", '--format=json', id)
    if net.nil?
      raise(Puppet::ExecutionFailure, "Can't retrieve #{type}-show because Neutron or Keystone API is not available.")
    end

    self.find_and_parse_json(net).each do |line|
      k = line['Field']
      v = line['Value']
      if ['True', 'False'].include? v.to_s.capitalize
        v = "#{v}".capitalize
      elsif v.is_a? String and v =~ /\n/
        v = v.split(/\n/)
      elsif v.is_a? Numeric
        v = "#{v}"
      else
        v = "#{v}"
      end
      attrs[k] = v
    end

    return attrs
  end

  def self.list_router_ports(router_name_or_id)
    results = []
    cmd_output = auth_neutron("router-port-list",
                              '--format=json',
                              router_name_or_id)

    self.find_and_parse_json(cmd_output).each do |port|
      if port['fixed_ips']
        fixed_ips = JSON.parse(port['fixed_ips'])
        port['subnet_id'] = fixed_ips['subnet_id']
        port.delete('fixed_ips')
      end
      results << port
    end

    return results
  end

  def self.get_tenant_id(catalog, name, domain='Default')
    instance_type = 'keystone_tenant'
    instance = catalog.resource("#{instance_type.capitalize!}[#{name}]")
    if ! instance
      instance = Puppet::Type.type(instance_type).instances.find do |i|
        # We need to check against the Default domain name because of
        # https://review.openstack.org/#/c/226919/ which changed the naming
        # format for the tenant to include ::<Domain name>. This should be
        # removed when we drop the resource without a domain name.
        # TODO(aschultz): remove ::domain lookup as part of M-cycle
        i.provider.name == name || i.provider.name == "#{name}::#{domain}"
      end
    end
    if instance
      return instance.provider.id
    else
      fail("Unable to find #{instance_type} for name #{name}")
    end
  end

  def self.parse_creation_output(data)
    hash = {}
    data.split("\n").compact.each do |line|
      if line.include? '='
        hash[line.split('=').first] = line.split('=', 2)[1].gsub(/\A"|"\Z/, '')
      end
    end
    hash
  end

end
