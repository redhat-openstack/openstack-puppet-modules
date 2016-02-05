# This file must be compatible with Ruby 1.8.7 in order to work on EL6.
module Puppet::Parser::Functions

  # Generate fluentd config from Hash.
  newfunction(:fluent_config, :type => :rvalue) do |args|
    config = args[0]

    header = "# Managed by Puppet.\n"

    # NOTE: Hash iteration order is arbitrary in ruby 1.8.7
    # https://projects.puppetlabs.com/issues/16266
    config.keys.sort.inject(header) do |result, plugin_type|
      plugin_config = config[plugin_type]
      result << function_fluent_plugin_config([plugin_type, plugin_config])
    end.chomp
  end

  # Generate fluentd plugin config from Hash
  newfunction(:fluent_plugin_config, :type => :rvalue) do |args|
    plugin_type = args[0]
    plugin_config = args[1]

    tag_pattern = plugin_config.delete('tag_pattern')

    config_body = ''

    # NOTE: Hash iteration order is arbitrary in ruby 1.8.7
    # https://projects.puppetlabs.com/issues/16266
    plugin_config.keys.sort.each do |key|
      value = plugin_config[key]

      if value.is_a?(Array)
        value.each do |plugin_sub_config|
          config_body << function_fluent_plugin_config([key, plugin_sub_config])
        end
      else
        config_body << [key, value].join(' ') << "\n"
      end
    end

    "<#{plugin_type} #{tag_pattern}>\n#{config_body}</#{plugin_type}>\n\n"
  end
end
