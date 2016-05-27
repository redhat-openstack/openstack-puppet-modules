module Puppet::Parser::Functions
  newfunction(
      :pacemaker_cluster_options,
      type: :rvalue,
      arity: 1,
      doc: <<-eof
Convert the cluster options to the "pcs cluster create" CLI options string
eof
  ) do |args|
    options = args[0]
    break '' unless options
    break options if options.is_a? String
    if options.is_a? Hash
      options_array = []
      options.each do |option, value|
        option = "--#{option}" unless option.start_with? '--'
        if value.is_a? TrueClass or value.is_a? FalseClass
          options_array << option if value
        else
          options_array << option
          options_array << value
        end
      end
      options = options_array
    end
    [options].flatten.join ' '
  end
end
