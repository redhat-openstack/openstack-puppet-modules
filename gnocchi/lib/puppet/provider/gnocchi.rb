require 'json'
require 'puppet/util/inifile'

class Puppet::Provider::Gnocchi < Puppet::Provider

  def self.conf_filename
    '/etc/gnocchi/gnocchi.conf'
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

  def self.gnocchi_credentials
    @gnocchi_credentials ||= get_gnocchi_credentials
  end

  def self.get_gnocchi_credentials
    auth_keys = ['auth_host', 'auth_port', 'auth_protocol',
                 'admin_tenant_name', 'admin_user', 'admin_password']
    conf = gnocchi_conf
    if conf and conf['keystone_authtoken'] and
        auth_keys.all?{|k| !conf['keystone_authtoken'][k].nil?}
      return Hash[ auth_keys.map \
                   { |k| [k, conf['keystone_authtoken'][k].strip] } ]
    else
      raise(Puppet::Error, "File: #{conf_filename} does not contain all \
required sections.  Gnocchi types will not work if gnocchi is not \
correctly configured.")
    end
  end

  def gnocchi_credentials
    self.class.gnocchi_credentials
  end

  def self.auth_endpoint
    @auth_endpoint ||= get_auth_endpoint
  end

  def self.get_auth_endpoint
    q = gnocchi_credentials
    "#{q['auth_protocol']}://#{q['auth_host']}:#{q['auth_port']}/v2.0/"
  end

  def self.gnocchi_conf
    return @gnocchi_conf if @gnocchi_conf
    @gnocchi_conf = Puppet::Util::IniConfig::File.new
    @gnocchi_conf.read(conf_filename)
    @gnocchi_conf
  end

  def self.auth_gnocchi(*args)
    q = gnocchi_credentials
    authenv = {
      :OS_AUTH_URL    => self.auth_endpoint,
      :OS_USERNAME    => q['admin_user'],
      :OS_TENANT_NAME => q['admin_tenant_name'],
      :OS_PASSWORD    => q['admin_password']
    }
    begin
      withenv authenv do
        gnocchi(args)
      end
    rescue Exception => e
      if (e.message =~ /\[Errno 111\] Connection refused/) or
          (e.message =~ /\(HTTP 400\)/)
        sleep 10
        withenv authenv do
          gnocchi(args)
        end
      else
       raise(e)
      end
    end
  end

  def auth_gnocchi(*args)
    self.class.auth_gnocchi(args)
  end

  def gnocchi_manage(*args)
    cmd = args.join(" ")
    output = `#{cmd}`
    $?.exitstatus
  end

  def self.reset
    @gnocchi_conf        = nil
    @gnocchi_credentials = nil
  end

  def self.list_gnocchi_resources(type, *args)
    json = auth_gnocchi("--json", "#{type}-list", *args)
    return JSON.parse(json)
  end

  def self.get_gnocchi_resource_attrs(type, id)
    json = auth_gnocchi("--json", "#{type}-show", id)
    return JSON.parse(json)
  end

end
