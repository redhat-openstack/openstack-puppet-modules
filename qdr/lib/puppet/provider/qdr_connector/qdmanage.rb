require "json"

Puppet::Type.type(:qdr_connector).provide(:qdmanage) do

  # should rely on environment rather fq path
  commands :qdmanage => '/usr/bin/qdmanage'

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.get_list_of_connectors
    begin
      @connectors=JSON.load(qdmanage('QUERY','--type=connector'))
    rescue Puppet::ExecutionFailure => e
      @connectors = {}
    end
  end

  def self.get_connector_properties(connector)
    connector_properties = {}
 
    connector_properties[:provider]       = :qdmanage
    connector_properties[:ensure]         = :present
    connector_properties[:name]           = connector["name"]
    connector_properties[:addr]           = connector["addr"]
    connector_properties[:port]           = connector["port"]
    connector_properties[:role]           = connector["role"].to_s
    connector_properties[:allow_redirect]       = connector["allowRedirect"].to_s
    connector_properties[:max_frame_size]       = connector["maxFrameSize"].to_s
    connector_properties[:idle_timeout_seconds] = connector["idleTimeoutSeconds"].to_s
    connector_properties[:strip_annotations]    = connector["stripAnnotations"].to_s    

    connector_properties
  end   

  def self.instances
    connectors = []
    get_list_of_connectors.each do |connector|
      connectors << new( :name => connector["name"],
                        :ensure            => :present,
                        :addr              => connector["addr"],
                        :port              => connector["port"],
                        :role              => connector["role"].to_s,
                        :allow_redirect    => connector["allowRedirect"].to_s,
                        :max_frame_size    => connector["maxFrameSize"].to_s,
                        :idle_timeout_seconds  => connector["idleTimeoutSeconds"].to_s,
                        :strip_annotations => connector["stripAnnotations"].to_s)      
    end
    connectors                                  
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

  def set_connector
    # TODO(ansmith) - full CRUD once supported by qdmanage
    if @property_flush[:ensure] == :absent
      notice("Connector destroy not supported")
      return
    end

    begin
      # TODO(ansmith) - name, addr:port uniqueness check
      qdmanage('CREATE',
               '--type=connector',
               '--name',
               resource[:name],
               'addr='+resource[:addr],
               'port='+resource[:port],
               'role='+resource[:role].to_s,
               'allowRedirect='+resource[:allow_redirect].to_s,
               'maxFrameSize='+resource[:max_frame_size].to_s,
               'idleTimeoutSeconds='+resource[:idle_timeout_seconds].to_s,
               'stripAnnotations='+resource[:strip_annotations].to_s)      
    rescue Puppet::ExecutionFailure => e
      return
    end
    
  end
  
  def flush
    set_connector

    @property_hash = self.class.get_connector_properties(resource[:name])
  end

end
