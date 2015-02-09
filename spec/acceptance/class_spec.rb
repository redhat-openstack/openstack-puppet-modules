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

    # TODO: It'd be nice to do this independently of install dir name
    describe file('/opt/opendaylight-0.2.2/') do
      it { should be_directory }
      it { should be_owned_by 'odl' }
      it { should be_grouped_into 'odl' }
      it { should be_mode '775' }
    end

    describe yumrepo('opendaylight') do
      it { should exist }
      it { should be_enabled }
    end

    describe package('opendaylight') do
      it { should be_installed }
    end

    describe service('opendaylight') do
      it { should be_enabled }
      it { should be_enabled.with_level(3) }
      it { should be_running }
    end

    # OpenDaylight will appear as a Java process
    describe process('java') do
      it { should be_running }
    end

    # TODO: It'd be nice to do this independently of install dir name
    describe user('odl') do
      it { should exist }
      it { should belong_to_group 'odl' }
      it { should have_home_directory '/opt/opendaylight-0.2.2' }
    end

    describe file('/home/odl') do
      # Home dir shouldn't be created for odl user
      it { should_not be_directory }
    end

    describe file('/usr/lib/systemd/system/opendaylight.service') do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode '644' }
    end
  end

  context "testing Karaf config file" do
    context "using default features" do
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

        # Punt validations to shared fn in spec_helper_acceptance
        validate_karaf_config(default_features)
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

        # Punt validations to shared fn in spec_helper_acceptance
        validate_karaf_config(default_features + extra_features)
      end
    end

    context "overriding default features" do
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

        # Punt validations to shared fn in spec_helper_acceptance
        validate_karaf_config(default_features)
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

        # Punt validations to shared fn in spec_helper_acceptance
        validate_karaf_config(default_features + extra_features)
      end
    end
  end
end
