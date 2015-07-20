require 'uri'
require 'faraday'
# Host registry type

Puppet::Type.type(:midonet_host_registry).provide(:midonet_api_caller) do

  def create
    define_connection(resource[:midonet_api_url])
    tz = call_get_tunnelzone()
    if tz.empty?
      # Tunnel zone does not exist. It should. Then
      # create a tunnelzone with current values. Note
      # the exists? applies at the host in a given
      # tunnelzone, so it is fair to create a tunnelzone
      message = Hash.new
      message['name'] = resource[:tunnelzone_name]
      message['type'] = resource[:tunnelzone_type]
      tz = call_create_tunnelzone(message)
      tz_id = tz[0]['id']
    else
      tz_type = tz[0]['type']
      if tz_type != resource[:tunnelzone_type].to_s
        raise "Tunnel zone already exists in type #{tz[0]['type']} whereas you are associating a host in a type #{resource[:tunnelzone_type]}"
      else
        tz_id = tz[0]['id']
      end
    end

    host = call_get_host()
    if host.empty?
      raise 'Midonet agent does not run on the host you are trying to register'
    else
      host_id = host[0]['id']
    end

    host_id = host[0]['id']

    message = Hash.new
    message['hostId'] = "#{host_id}"
    message['ipAddress'] = "#{resource[:underlay_ip_address]}"

    call_create_tunnelzone_host(tz_id, message)
  end

  def destroy
    define_connection(resource[:midonet_api_url])

    tz = call_get_tunnelzone()
    if tz.empty?
      return
    end
    tz_id = tz[0]['id']

    host = call_get_host()
    if host.empty?
      return
    end
    host_id = host[0]['id']

    reg_host = call_get_tunnelzone_host(tz_id, host_id)
    if reg_host.empty?
      return
    end

    # Delete host from tunnelzone
    call_delete_tunnelzone_host(tz_id, host_id)

    # We can delete the tunnelzone if no host registered left
    if call_get_tunnelzone_hosts(tz_id).empty?
      call_delete_tunnelzone(tz_id)
    end

  end

  def exists?
    define_connection(resource[:midonet_api_url])

    tz = call_get_tunnelzone()
    if tz.empty?
      return false
    end
    tz_id = tz[0]['id']

    host = call_get_host()
    if host.empty?
      return false
    end
    host_id = host[0]['id']

    reg_host = call_get_tunnelzone_host(tz_id, host_id)
    if reg_host.empty?
      return false
    end

    return true
  end

  def define_connection(url)

    @connection = Faraday.new(:url => url,
                              :ssl => { verify: false }) do |builder|
        builder.request(:retry, {
          :max        => 5,
          :interval   => 0.05,
          :exceptions => [
            Faraday::Error::TimeoutError,
            Faraday::ConnectionFailed,
            Errno::ETIMEDOUT,
            'Timeout::Error',
          ],
        })
        builder.use(Faraday::Request::BasicAuthentication, resource[:username], resource[:password])
        builder.adapter(:net_http)
    end
  end

  def call_get_tunnelzone()
    res = @connection.get do |req|
      req.url "/midonet-api/tunnel_zones"
    end

    output = JSON.parse(res.body)
    return output.select{ |tz| tz['name'] == resource[:tunnelzone_name].to_s }
  end

  def call_get_host()
    res = @connection.get do |req|
      req.url "/midonet-api/hosts"
    end

    output = JSON.parse(res.body)
    return output.select{ |host| host['name'] == resource[:hostname].to_s }
  end

  def call_create_tunnelzone(message)

    res = @connection.post do |req|
      req.url "/midonet-api/tunnel_zones"
      req.headers['Content-Type'] = "application/vnd.org.midonet.TunnelZone-v1+json"
      req.body = message.to_json
    end

    return call_get_tunnelzone()

  end

  def call_create_tunnelzone_host(tz_id, message)

    res = @connection.post do |req|
      req.url "/midonet-api/tunnel_zones/#{tz_id}/hosts"
      req.headers['Content-Type'] = "application/vnd.org.midonet.TunnelZoneHost-v1+json"
      req.body = message.to_json
    end
  end

  def call_get_tunnelzone_hosts(tz_id)
    res = @connection.get do |req|
      req.url "/midonet-api/tunnel_zones/#{tz_id}/hosts"
    end

    return JSON.parse(res.body)
  end

  def call_get_tunnelzone_host(tz_id, host_id)
    return call_get_tunnelzone_hosts(tz_id).select{ |host| host['id'] == host_id }
  end


  def call_delete_tunnelzone(tz_id)
    res = @connection.delete do |req|
      req.url "/midonet-api/tunnel_zones/#{tz_id}"
    end
  end

  def call_delete_tunnelzone_host(tz_id, host_id)
    res = @connection.delete do |req|
      req.url "/midonet-api/tunnel_zones/#{tz_id}/hosts/#{host_id}"
    end
  end

  private :call_create_tunnelzone,
          :call_create_tunnelzone_host,
          :call_delete_tunnelzone,
          :call_delete_tunnelzone_host,
          :call_get_host,
          :call_get_tunnelzone,
          :call_get_tunnelzone_host,
          :call_get_tunnelzone_hosts,
          :define_connection

end
