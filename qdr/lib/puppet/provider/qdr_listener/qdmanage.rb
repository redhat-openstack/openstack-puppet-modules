require "json"

Puppet::Type.type(:qdr_listener).provide(:qdmanage) do

  # should rely on environment rather fq path
  commands :qdmanage => '/usr/bin/qdmanage'

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.get_list_of_listeners
    begin
      @listeners=JSON.load(qdmanage('QUERY','--type=listener'))
    rescue Puppet::ExecutionFailure => e
      @listeners = {}
    end
  end

  def self.get_listener_properties(listener)
    listener_properties = {}
 
    listener_properties[:provider]  = :qdmanage
    listener_properties[:ensure]    = :present
    listener_properties[:name]      = listener["name"]
    listener_properties[:addr]      = listener["addr"]
    listener_properties[:port]      = listener["port"]
    listener_properties[:role]      = listener["role"].to_s
    listener_properties[:sasl_mechanisms] = listener["saslMechanisms"].to_s
    listener_properties[:auth_peer] = listener["authenticatePeer"].to_s
    listener_properties[:require_encryption] = listener["requireEncryption"].to_s    
    listener_properties[:require_ssl] = listener["requireSsl"].to_s
    listener_properties[:max_frame_size] = listener["maxFrameSize"].to_s
    
    listener_properties
  end   

  def self.instances
    listeners = []
    get_list_of_listeners.each do |listener|
      listeners << new( :name => listener["name"],
                        :ensure => :present,
                        :addr   => listener["addr"],
                        :port   => listener["port"],
                        :role   => listener["role"].to_s,
                        :sasl_mechanisms => listener["saslMechanisms"].to_s,
                         :auth_peer => listener["authenticatePeer"].to_s,
                        :require_encryption => listener["requireEncryption"].to_s,
                        :require_ssl => listener["requireSsl"].to_s,
                        :max_frame_size => listener["maxFrameSize"].to_s)
    end
    listeners                                  
  end
  
  def create
    @property_flush[:ensure] = :present
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def set_listener
    # TODO(ansmith) - full CRUD once supported by qdmanage
    if @property_flush[:ensure] == :absent
      notice("Listener destroy not supported")
      return
    end

    begin
      # TODO(ansmith) - name, addr:port uniqueness check
      qdmanage('CREATE',
               '--type=listener',
               '--name',
               resource[:name],
               'addr='+resource[:addr],
               'port='+resource[:port],
               'role='+resource[:role].to_s,
               'saslMechanisms='+resource[:sasl_mechanisms].to_s,
               'authenticatePeer='+resource[:auth_peer].to_s,
               'requireEncryption='+resource[:require_encryption].to_s,              
               'requireSsl='+resource[:require_ssl].to_s,
               'maxFrameSize='+resource[:max_frame_size].to_s)
    rescue Puppet::ExecutionFailure => e
      return
    end
    
  end
  
  def flush
    set_listener

    @property_hash = self.class.get_listener_properties(resource[:name])
  end

end
