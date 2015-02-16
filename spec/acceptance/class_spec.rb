require 'spec_helper_acceptance'

# Note that helpers (`should`, `be_running`...) are documented here:
# http://serverspec.org/resource_types.html
describe 'opendaylight class' do

  context 'passing no params' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'opendaylight': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    # Use helper fn to run generic validations
    generic_validations

    # Call specialized helper fn for RPM-type install validations
    # NB: This is defined in spec_helper_acceptance
    rpm_validations
  end

  describe "testing Karaf config file" do
    describe "using default features" do
      # NB: This list should be the same as the one in opendaylight::params
      default_features = ['config', 'standard', 'region', 'package', 'kar', 'ssh', 'management']
      context "and not passing extra features" do
        # Using puppet_apply as a helper
        it 'should work idempotently with no errors' do
          pp = <<-EOS
          class { 'opendaylight':
          }
          EOS

          # Run it twice and test for idempotency
          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes  => true)
        end

        # Call specialized helper fn for Karaf config validations
        # NB: This is defined in spec_helper_acceptance
        karaf_config_validations(default_features)
      end

      context "and passing extra features" do
      # Using puppet_apply as a helper
        extra_features = ["odl-base-all", "odl-ovsdb-all"]
        it 'should work idempotently with no errors' do
          pp = <<-EOS
          class { 'opendaylight':
            extra_features => #{extra_features},
          }
          EOS

          # Run it twice and test for idempotency
          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes  => true)
        end

        # Call specialized helper fn for Karaf config validations
        # NB: This is defined in spec_helper_acceptance
        karaf_config_validations(default_features + extra_features)
      end
    end

    describe "overriding default features" do
      default_features = ["standard", "ssh"]
      context "and not passing extra features" do
        # Using puppet_apply as a helper
        it 'should work idempotently with no errors' do
          pp = <<-EOS
          class { 'opendaylight':
            default_features => #{default_features},
          }
          EOS

          # Run it twice and test for idempotency
          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes  => true)
        end

        # Call specialized helper fn for Karaf config validations
        # NB: This is defined in spec_helper_acceptance
        karaf_config_validations(default_features)
      end

      context "and passing extra features" do
        # These are real but arbitrarily chosen features
        extra_features = ["odl-base-all", "odl-ovsdb-all"]
        # Using puppet_apply as a helper
        it 'should work idempotently with no errors' do
          pp = <<-EOS
          class { 'opendaylight':
            default_features => #{default_features},
            extra_features => #{extra_features},
          }
          EOS

          # Run it twice and test for idempotency
          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes  => true)
        end

        # Call specialized helper fn for Karaf config validations
        # NB: This is defined in spec_helper_acceptance
        karaf_config_validations(default_features + extra_features)
      end
    end
  end

  # All tests for tarball install method
  describe "tarball install method" do
    # TODO: This is never being applied
    pp = <<-EOS
    class { 'opendaylight':
      install_method => 'tarball'
    }
    EOS

    # Use helper fn to run generic validations
    generic_validations

    # TODO: Call specialized helper fn for tarball-type install validations
  end
end
