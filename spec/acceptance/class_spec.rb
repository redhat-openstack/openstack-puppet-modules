require 'spec_helper_acceptance'

# NB: There are a large number of helper functions used in these tests.
# They make this code much more friendly, but may need to be referenced.
#   The serverspec helpers (`should`, `be_running`...) are documented here:
#     http://serverspec.org/resource_types.html
#   Custom helpers (`install_odl`, `*_validations`) are in:
#     <this module>/spec/spec_helper_acceptance.rb

describe 'opendaylight class' do
  describe 'testing install methods' do
    # Apply to host selectively based on install method
    # Install method is passed via environment var, set in Rakefile
    if ENV['INSTALL_METHOD'] == 'tarball'
      # Call specialized helper fn to install OpenDaylight from a tarball
      install_odl(install_method: 'tarball')

      # TODO: Call specialized helper fn for tarball-type install validations
    else
      # Call specialized helper fn to install OpenDaylight from an RPM
      install_odl(install_method: 'rpm')

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
end
