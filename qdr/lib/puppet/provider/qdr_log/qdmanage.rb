require "json"

Puppet::Type.type(:qdr_log).provide(:qdmanage) do

  # should rely on environment rather fq path
  commands :qdmanage => '/usr/bin/qdmanage'

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.get_list_of_loggers
    begin
      @loggers=JSON.load(qdmanage('QUERY','--type=log'))
    rescue Puppet::ExecutionFailure => e
      @loggers = {}
    end
  end

  def self.get_logger_properties(listener)
    logger_properties = {}
 
    logger_properties[:provider]  = :qdmanage
    logger_properties[:name]      = logger["name"]
    logger_properties[:module]    = logger["module"]
    
    logger_properties
  end   

  def self.instances
    loggers = []
    get_list_of_loggers.each do |logger|
      loggers << new( :name => logger["name"],
                        :module => logger["module"])
    end
    loggers                                  
  end
  
#  def create
#    @property_flush[:ensure] = :present
#  end

  def exists?
    @property_hash[:ensure] == :present
  end

#  def destroy
#    @property_flush[:ensure] = :absent
#  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def set_logger
    # TODO(ansmith) - full CRUD once supported by qdmanage

    begin
      # TODO(ansmith) - name, addr:port uniqueness check
      qdmanage('UPDATE',
               '--type=log',
               '--name',
               resource[:name])
    rescue Puppet::ExecutionFailure => e
      return
    end
    
  end
  
  def flush
    set_logger

    @property_hash = self.class.get_logger_properties(resource[:name])
  end

end
