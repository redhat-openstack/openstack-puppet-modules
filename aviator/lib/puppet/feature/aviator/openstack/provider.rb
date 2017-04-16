module Aviator
module Openstack

  module Provider

    class MultipleServiceApisError < StandardError
      def initialize(service, entries, request_name)
        types = entries.map{|e| e[:type] }.join("\n - ")
        msg = <<EOF
Multiple entries for the #{ service } service were found in the api catalog:

 - #{ types }

I'm unable to guess which one it is you want to use. To fix this problem, you'll need to
do one of two things:

  1) Indicate in the config file the api version you want to use:

      production:
        provider: openstack
        ...
        #{ service }_service:
          api_version: v2

  2) Indicate the api version when you call the request:

      session.#{ service }_service.request :#{ request_name }, :api_version => :v2 { ... }

If you combine the two methods, method #2 will override method #1

EOF
        super(msg)
      end
    end

    class << self

      def find_request(service, name, session_data, options)
        service = service.to_s
        endpoint_type = options[:endpoint_type]
        endpoint_types = if endpoint_type
                           [endpoint_type.to_s.camelize]
                         else
                           ['Public', 'Admin']
                         end

        namespace = Aviator.const_get('Openstack') \
                           .const_get(service.camelize) \
                           .const_get('Requests')

        if options[:api_version]
          m = options[:api_version].to_s.match(/(v\d+)\.?\d*/)
          version = m[1].to_s.camelize unless m.nil?
        end

        version ||= infer_version(session_data, name, service)

        unless version.nil?
          version = version.to_s.camelize
        end

        return nil unless version && namespace.const_defined?(version)

        namespace = namespace.const_get(version, name)

        endpoint_types.each do |endpoint_type|
          name = name.to_s.camelize

          next unless namespace.const_defined?(endpoint_type)
          next unless namespace.const_get(endpoint_type).const_defined?(name)

          return namespace.const_get(endpoint_type).const_get(name)
        end

        nil
      end


      def root_dir
        Pathname.new(__FILE__).join('..').expand_path
      end


      def request_file_paths(service)
          Dir.glob(Pathname.new(__FILE__).join(
            '..',
             service.to_s,
            'requests',
            '**',
            '*.rb'
            ).expand_path
          )
      end


      private

      def infer_version(session_data, request_name, service)
        if session_data.has_key?(:auth_service) && session_data[:auth_service][:api_version]
        session_data[:auth_service][:api_version].to_sym

        elsif session_data.has_key?(:auth_service) && session_data[:auth_service][:host_uri]
          m = session_data[:auth_service][:host_uri].match(/(v\d+)\.?\d*/)
          return m[1].to_sym unless m.nil?

        elsif session_data.has_key? :base_url
          m = session_data[:base_url].match(/(v\d+)\.?\d*/)
          return m[1].to_sym unless m.nil?

        elsif session_data.has_key?(:body) && session_data[:body].has_key?(:access)
          service_specs = session_data[:body][:access][:serviceCatalog].select{|s| s[:type].match("#{ service }(v\d+)?") }
          raise MultipleServiceApisError.new(service, service_specs, request_name) unless service_specs.length <= 1
          raise Aviator::Service::MissingServiceEndpointError.new(service.to_s, request_name) unless service_specs.length > 0
          version = service_specs[0][:endpoints][0][:publicURL].match(/(v\d+)\.?\d*/)
          version ? version[1].to_sym : :v1

        elsif session_data.has_key?(:headers) && session_data[:headers].has_key?("x-subject-token")
          service_specs = session_data[:body][:token][:catalog].select{|s| s[:type].match("#{ service }(v\d+)?") }
          raise MultipleServiceApisError.new(service, service_specs, request_name) unless service_specs.length <= 1
          raise Aviator::Service::MissingServiceEndpointError.new(service.to_s, request_name) unless service_specs.length > 0
          version = service_specs[0][:endpoints][0][:url].match(/(v\d+)\.?\d*/)
          version ? version[1].to_sym : :v1
        end
      end

    end # class << self

  end # module Provider

end # module Openstack
end # module Aviator
