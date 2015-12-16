module Puppet::Parser::Functions
  newfunction(:fluent_plugin_config, type: :rvalue) do |args|
    plugin_type = args[0]
    plugin_config = args[1]

    tag_pattern = plugin_config.delete('tag_pattern')

    config_body = plugin_config.each_with_object('') do |(key, value), result|
      if value.is_a?(Array)
        value.each do |plugin_sub_config|
          result << function_fluent_plugin_config([key, plugin_sub_config])
        end
      else
        result << [key, value].join(' ') << "\n"
      end
    end

    "<#{plugin_type} #{tag_pattern}>\n#{config_body}</#{plugin_type}>\n\n"
  end

  newfunction(:fluent_config, type: :rvalue) do |args|
    config = args[0]

    header = "# Managed by Puppet.\n"
    config.each_with_object(header) do |(plugin_type, plugin_config), result|
      result << function_fluent_plugin_config([plugin_type, plugin_config])
    end.chomp
  end
end
