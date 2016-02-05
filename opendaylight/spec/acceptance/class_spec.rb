require 'spec_helper_acceptance'

# NB: There are a large number of helper functions used in these tests.
# They make this code much more friendly, but may need to be referenced.
#   The serverspec helpers (`should`, `be_running`...) are documented here:
#     http://serverspec.org/resource_types.html
#   Custom helpers (`install_odl`, `*_validations`) are in:
#     <this module>/spec/spec_helper_acceptance.rb

describe 'opendaylight class' do
  describe 'testing install methods' do
    # Call specialized helper fn to install OpenDaylight
    install_odl

    # Run checks specific to install type, via env var passed from Rakefile
    if ENV['INSTALL_METHOD'] == 'tarball'
      # Call specialized helper fn for tarball-type install validations
      tarball_validations
    else
      # Call specialized helper fn for RPM-type install validations
      rpm_validations
    end

    # Use helper fn to run generic validations
    generic_validations
  end

  describe 'testing Karaf config file' do
    describe 'using default features' do
      context 'and not passing extra features' do
        # Call specialized helper fn to install OpenDaylight
        install_odl

        # Call specialized helper fn for Karaf config validations
        karaf_config_validations
      end

      context 'and passing extra features' do
        # These are real but arbitrarily chosen features
        extra_features = ['odl-base-all', 'odl-ovsdb-all']

        # Call specialized helper fn to install OpenDaylight
        install_odl(extra_features: extra_features)

        # Call specialized helper fn for Karaf config validations
        karaf_config_validations(extra_features: extra_features)
      end
    end

    describe 'overriding default features' do
      # These are real but arbitrarily chosen features
      default_features = ['standard', 'ssh']

      context 'and not passing extra features' do
        # Call specialized helper fn to install OpenDaylight
        install_odl(default_features: default_features)

        # Call specialized helper fn for Karaf config validations
        karaf_config_validations(default_features: default_features)
      end

      context 'and passing extra features' do
        # These are real but arbitrarily chosen features
        extra_features = ['odl-base-all', 'odl-ovsdb-all']

        # Call specialized helper fn to install OpenDaylight
        install_odl(default_features: default_features,
                    extra_features: extra_features)

        # Call specialized helper fn for Karaf config validations
        karaf_config_validations(default_features: default_features,
                                 extra_features: extra_features)
      end
    end
  end

  describe 'testing REST port config file' do
    context 'using default port' do
      # Call specialized helper fn to install OpenDaylight
      install_odl

      # Call specialized helper fn for REST port config validations
      port_config_validations
    end

    context 'overriding default port' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(odl_rest_port: 7777)

      # Call specialized helper fn for REST port config validations
      port_config_validations(odl_rest_port: 7777)
    end
  end

  describe 'testing custom logging verbosity' do
    context 'using default log levels' do
      # Call specialized helper fn to install OpenDaylight
      install_odl

      # Call specialized helper fn for custom logger verbosity validations
      log_level_validations
    end

    context 'adding one custom log level' do
      custom_log_levels = { 'org.opendaylight.ovsdb' => 'TRACE' }

      # Call specialized helper fn to install OpenDaylight
      install_odl(log_levels: custom_log_levels)

      # Call specialized helper fn for custom logger verbosity validations
      log_level_validations(log_levels: custom_log_levels)
    end

    context 'adding two custom log level' do
      custom_log_levels = { 'org.opendaylight.ovsdb' => 'TRACE',
                            'org.opendaylight.ovsdb.lib' => 'INFO' }

      # Call specialized helper fn to install OpenDaylight
      install_odl(log_levels: custom_log_levels)

      # Call specialized helper fn for custom logger verbosity validations
      log_level_validations(log_levels: custom_log_levels)
    end
  end

  describe 'testing ODL OVSDB L3 config' do
    context 'using enable_l3 default' do
      # Call specialized helper fn to install OpenDaylight
      install_odl

      # Call specialized helper fn for ODL OVSDB L3 config validations
      enable_l3_validations
    end

    context 'using "no" for enable_l3' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(enable_l3: 'no')

      # Call specialized helper fn for ODL OVSDB L3 config validations
      enable_l3_validations(enable_l3: 'no')
    end

    context 'using "yes" for enable_l3' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(enable_l3: 'yes')

      # Call specialized helper fn for ODL OVSDB L3 config validations
      enable_l3_validations(enable_l3: 'yes')
    end

    context 'using false for enable_l3' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(enable_l3: false)

      # Call specialized helper fn for ODL OVSDB L3 config validations
      enable_l3_validations(enable_l3: false)
    end

    context 'using true for enable_l3' do
      # Call specialized helper fn to install OpenDaylight
      install_odl(enable_l3: true)

      # Call specialized helper fn for ODL OVSDB L3 config validations
      enable_l3_validations(enable_l3: true)
    end
  end
end
