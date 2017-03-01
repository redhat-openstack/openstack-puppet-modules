require 'json'
require 'puppet/util/inifile'

class Puppet::Provider::Tuskar < Puppet::Provider

  def self.conf_filename
    '/etc/tuskar/tuskar.conf'
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

  def self.tuskar_credentials
    @tuskar_credentials ||= get_tuskar_credentials
  end

  def self.get_tuskar_credentials
    auth_keys = ['auth_host', 'auth_port', 'auth_protocol',
                 'admin_tenant_name', 'admin_user', 'admin_password']
    conf = tuskar_conf
    if conf and conf['keystone_authtoken'] and
        auth_keys.all?{|k| !conf['keystone_authtoken'][k].nil?}
      return Hash[ auth_keys.map \
                   { |k| [k, conf['keystone_authtoken'][k].strip] } ]
    else
      raise(Puppet::Error, "File: #{conf_filename} does not contain all \
required sections.  Tuskar types will not work if tuskar is not \
correctly configured.")
    end
  end

  def tuskar_credentials
    self.class.tuskar_credentials
  end

  def self.auth_endpoint
    @auth_endpoint ||= get_auth_endpoint
  end

  def self.get_auth_endpoint
    q = tuskar_credentials
    "#{q['auth_protocol']}://#{q['auth_host']}:#{q['auth_port']}/v2.0/"
  end

  def self.tuskar_conf
    return @tuskar_conf if @tuskar_conf
    @tuskar_conf = Puppet::Util::IniConfig::File.new
    @tuskar_conf.read(conf_filename)
    @tuskar_conf
  end

  def self.auth_tuskar(*args)
    q = tuskar_credentials
    authenv = {
      :OS_AUTH_URL    => self.auth_endpoint,
      :OS_USERNAME    => q['admin_user'],
      :OS_TENANT_NAME => q['admin_tenant_name'],
      :OS_PASSWORD    => q['admin_password']
    }
    begin
      withenv authenv do
        tuskar(args)
      end
    rescue Exception => e
      if (e.message =~ /\[Errno 111\] Connection refused/) or
          (e.message =~ /\(HTTP 400\)/)
        sleep 10
        withenv authenv do
          tuskar(args)
        end
      else
       raise(e)
      end
    end
  end

  def auth_tuskar(*args)
    self.class.auth_tuskar(args)
  end

  def tuskar_manage(*args)
    cmd = args.join(" ")
    output = `#{cmd}`
    $?.exitstatus
  end

  def self.reset
    @tuskar_conf        = nil
    @tuskar_credentials = nil
  end

  def self.list_tuskar_resources(type, *args)
    json = auth_tuskar("--json", "#{type}-list", *args)
    return JSON.parse(json)
  end

  def self.get_tuskar_resource_attrs(type, id)
    json = auth_tuskar("--json", "#{type}-show", id)
    return JSON.parse(json)
  end

end
