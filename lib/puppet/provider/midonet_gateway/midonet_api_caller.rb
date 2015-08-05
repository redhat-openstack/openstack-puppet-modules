require 'uri'
require 'faraday'

if RUBY_VERSION == '1.8.7'
    require 'rubygems'
    require 'json'
end

Puppet::Type.type(:midonet_gateway).provide(:midonet_api_caller) do

  def create
    define_connection(resource[:midonet_api_url])
    # For each remote BGP peer, create a virtual port on
    # the MidoNet Provider Router that is going to be used
    # for the BGP communication. Connection to midonet api
    # is assumed

    router_id = call_get_provider_router()[0]['id']

    message = Hash.new
    message['portAddress'] = resource[:bgp_port]["port_address"]
    message['networkAddress'] = resource[:bgp_port]["net_prefix"]
    message['networkLength'] = resource[:bgp_port]["net_length"].to_i
    message['type'] = "Router"

    port = call_create_uplink_port(router_id, message)
    port_id = port[0]['id']

    # Configure BGP on the virtual ports. Port is
    # assumed created
    remote_peers = resource[:remote_peers]
    if remote_peers.class == Hash
       remote_peers = [remote_peers]
    end
    remote_peers.each do |rp|
      message = Hash.new
      message['localAS'] = resource[:local_as]
      message['peerAS'] = rp["as"]
      message['peerAddr'] = rp["ip"]

      call_add_bgp_to_port(port_id, message)
    end

    # In order to provide external connectivity for hosted
    # virtual machines, the floating IP network has to be
    # advertised to the BGP peers. BGP connection is assumed created
    bgp_connections = call_get_bgp_connections(port_id)

    #TODO(carmela): make this modification more elegant... or whatever
    advertise_networks = resource[:advertise_net]
    if advertise_networks.class == Hash
       advertise_networks = [advertise_networks]
    end
    bgp_connections.each do |bgp_c|
      advertise_networks.each do |net|
        message = Hash.new
        message['nwPrefix'] = net["net_prefix"]
        message['prefixLength'] = net["net_length"]

        bgp_id = bgp_c["id"]
        call_advertise_route_to_bgp(bgp_id, message)
      end
    end

    # Bind the MidoNet Provider Router’s virtual ports to
    # the physical network interfaces on the Gateway Nodes.
    # Host and port are assumed created. Interface name should
    # be an string
    host_id = call_get_host()[0]['id']

    message = Hash.new
    message['interfaceName'] = resource[:interface]
    message['portId'] = port_id

    call_bind_port_to_interface(host_id, message)

    # Configure a stateful port group
    spg = call_get_stateful_port_group()
    if spg.empty?
      message = Hash.new
      message['name'] = "uplink-spg"
      message['stateful'] = "true"
      message['tenantId'] = call_get_tenant()

      spg = call_create_stateful_port_group(message)
    end

    # Add the ports to the port group
    message = Hash.new
    message['portId'] = port_id

    call_add_ports_to_port_group(spg[0]["id"], message)
  end

  def destroy
    define_connection(resource[:midonet_api_url])

    router_id = call_get_provider_router()[0]['id']
    port_address = resource[:bgp_port]['port_address']

    port = call_get_uplink_port(router_id, port_address)
    port_id = port[0]["id"]

    # Delete the stateful port group
    #    TODO(carmela): delete only in case is the last port on the port group
    #    port_group_id = call_get_stateful_port_group()[0]['id']
    #    call_delete_stateful_port_group(port_group_id)

    # Delete uplink port
    call_delete_uplink_port(port_id)
  end

  def exists?
    define_connection(resource[:midonet_api_url])

    router = call_get_provider_router()
    if router.empty?
      raise 'MidoNet Provider Router does not exist. We cannot create uplink ports'
    end

    host = call_get_host()
    if host.empty?
      raise 'There is no MidoNet agent running on this host'
    end

    uplink_port = call_get_uplink_port(router[0]['id'], resource[:bgp_port]['port_address'])
    if uplink_port.empty?
      return false
    end

    return true
  end

  def define_connection(url)

    @connection = Faraday.new(:url => url,
                              :ssl => { :verify =>false }) do |builder|
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
        builder.request(:basic_auth, resource[:username], resource[:password])
        builder.adapter(:net_http)
    end

    @connection.headers['X-Auth-Token'] = call_get_token()
  end

  def call_get_token()
    res = @connection.get do |req|
      req.url "/midonet-api/login"
    end
    return JSON.parse(res.body)['key']
  end

  def call_get_tenant()
    res = @connection.get do |req|
      req.url "/midonet-api/tenants"
    end
    return JSON.parse(res.body)[0]['id']
  end

  def call_get_provider_router()
    res = @connection.get do |req|
      req.url "/midonet-api/routers"
    end
    output = JSON.parse(res.body)
    return output.select { |name| name['name'] == resource[:router]}
  end

  def call_get_stateful_port_group()
    res = @connection.get do |req|
      req.url "/midonet-api/port_groups"
    end
    output = JSON.parse(res.body)
    return output.select { |name| name['name'] == 'uplink-spg'}

  end

  def call_get_uplink_port(router_id, port_address)
    res = @connection.get do |req|
      req.url "/midonet-api/routers/#{router_id}/ports"
    end
    output =  JSON.parse(res.body)
    return output.select { |port| port['portAddress'] == port_address }

  end

  def call_get_host()
    res = @connection.get do |req|
      req.url "/midonet-api/hosts"
    end
    output = JSON.parse(res.body)
    return output.select{ |host| host['name'] == resource[:hostname].to_s }
  end

  def call_create_uplink_port(router_id, message)
    res = @connection.post do |req|
      req.url "/midonet-api/routers/#{router_id}/ports"
      req.headers['Content-Type'] = "application/vnd.org.midonet.Port-v2+json"
      req.body = message.to_json
    end
    return call_get_uplink_port(router_id, message["portAddress"])
  end

  def call_delete_uplink_port(port_id)
    res = @connection.delete do |req|
      req.url "/midonet-api/ports/#{port_id}"
    end
  end

  def call_add_bgp_to_port(port_id, message)
    res = @connection.post do |req|
      req.url "/midonet-api/ports/#{port_id}/bgps"
      req.headers['Content-Type'] = "application/vnd.org.midonet.Bgp-v1+json"
      req.body = message.to_json
    end
  end

  def call_get_bgp_connections(port_id)
    res = @connection.get do |req|
      req.url "/midonet-api/ports/#{port_id}/bgps"
    end
    output = JSON.parse(res.body)
    return output
  end

  def call_advertise_route_to_bgp(bgp_id, message)
    res = @connection.post do |req|
      req.url "/midonet-api/bgps/#{bgp_id}/ad_routes"
      req.headers['Content-Type'] = "application/vnd.org.midonet.AdRoute-v1+json"
      req.body = message.to_json
    end
  end

  def call_bind_port_to_interface(host_id, message)
    res = @connection.post do |req|
      req.url "/midonet-api/hosts/#{host_id}/ports"
      req.headers['Content-Type'] = "application/vnd.org.midonet.HostInterfacePort-v1+json"
      req.body = message.to_json
    end
  end

  def call_create_stateful_port_group(message)
    res = @connection.post do |req|
      req.url "/midonet-api/port_groups"
      req.headers['Content-Type'] = "application/vnd.org.midonet.PortGroup-v1+json"
      req.body = message.to_json
    end
    return call_get_stateful_port_group()
  end

  def call_add_ports_to_port_group(port_group_id, message)
    res = @connection.post do |req|
      req.url "/midonet-api/port_groups/#{port_group_id}/ports"
      req.headers['Content-Type'] = "application/vnd.org.midonet.PortGroupPort-v1+json"
      req.body = message.to_json
    end
  end

  def call_delete_stateful_port_group(port_group_id)
    res = @connection.delete do |req|
      req.url "/midonet-api/port_groups/#{port_group_id}"
    end
  end

  private :call_add_bgp_to_port
          :call_add_ports_to_port_group
          :call_advertise_route_to_bgp
          :call_bind_port_to_interface
          :call_create_stateful_port_group
          :call_create_uplink_port
          :call_delete_stateful_port_group
          :call_delete_uplink_port
          :call_get_bgp_connections
          :call_get_host
          :call_get_stateful_port_group
          :call_get_provider_router
          :call_get_tenant
          :call_get_uplink_port
          :define_connection
end
