require 'spec_helper_acceptance'

# Note that helpers (`should`, `be_running`...) are documented here:
# http://serverspec.org/resource_types.html
describe 'opendaylight class' do

  context 'default parameters' do
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
    describe file('/opt/opendaylight-0.2.1/') do
      it { should be_directory }
      it { should be_owned_by 'odl' }
      it { should be_grouped_into 'odl' }
      it { should be_mode '775' }
    end

    # TODO: It'd be nice to do this independently of install dir name
    describe file('/opt/opendaylight-0.2.1/etc/org.apache.karaf.features.cfg') do
      it { should be_file }
      it { should be_owned_by 'odl' }
      it { should be_grouped_into 'odl' }
      it { should be_mode '775' }
      it { should contain 'featuresBoot' }
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

    describe user('odl') do
      it { should exist }
      it { should belong_to_group 'odl' }
      it { should have_home_directory '/opt/opendaylight-0.2.1' }
    end

    describe file('/home/odl') do
      # Home dir shouldn't be created for odl user
      it { should_not be_directory }
    end
  end
end
