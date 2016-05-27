module Pacemaker
  # pacemaker options submodule
  # takes the options structure from the YAML file
  # other options sources can be implemented here
  module Options
    # the YAML file with pacemaker options
    # @return [String]
    def self.pacemaker_options_file
      File.join File.dirname(__FILE__), 'options.yaml'
    end

    # pacemaker options structure (class level)
    # @return [Hash]
    def self.pacemaker_options
      return @pacemaker_options if @pacemaker_options
      @pacemaker_options = YAML.load_file pacemaker_options_file
    end

    # pacemaker options structure (instance level)
    # @return [Hash]
    def pacemaker_options
      Pacemaker::Options.pacemaker_options
    end

    # maximum possible waiting time of retry functions
    # @return [Integer]
    def max_wait_time
      pacemaker_options[:retry_count] * pacemaker_options[:retry_step]
    end
  end
end
