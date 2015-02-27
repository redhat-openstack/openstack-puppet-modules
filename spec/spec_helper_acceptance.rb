require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

# Install Puppet on all Beaker hosts
unless ENV['BEAKER_provision'] == 'no'
  hosts.each do |host|
    # Install Puppet
    if host.is_pe?
      install_pe
    else
      install_puppet
    end
  end
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install opendaylight module on any/all Beaker hosts
    # TODO: Should this be done in host.each loop?
    puppet_module_install(:source => proj_root, :module_name => 'opendaylight')
    hosts.each do |host|
      # Install stdlib, a dependency of the odl mod
      # TODO: Why is 1 an acceptable exit code?
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      # Install archive, a dependency of the odl mod use for tarball-type installs
      on host, puppet('module', 'install', 'camptocamp-archive'), { :acceptable_exit_codes => [0] }
      # Install Java Puppet mod, a dependency of the tarball install method
      on host, puppet('module', 'install', 'puppetlabs-java'), { :acceptable_exit_codes => [0] }
    end
  end
end

#
# NB: These are a library of helper fns used by the Beaker tests
#

def install_odl(options = {})
  # NB: These param defaults should match the ones used by the opendaylight
  #   class, which are defined in opendaylight::params
  # TODO: Remove this possible source of bugs^^
  # Extract params if given, defaulting to odl class defaults if not
  install_method = options.fetch(:install_method, 'rpm')
  extra_features = options.fetch(:extra_features, [])
  default_features = options.fetch(:default_features, ['config', 'standard', 'region',
                                  'package', 'kar', 'ssh', 'management'])

  # Build script for consumption by Puppet apply
  it 'should work idempotently with no errors' do
    pp = <<-EOS
    class { 'opendaylight':
      install_method => #{install_method},
      default_features => #{default_features},
      extra_features => #{extra_features},
    }
    EOS

    # Apply to host selectively based on install method
    # TODO: Document how this works via Rake call path
    if install_method == 'rpm'
      apply_manifest_on('rpm', pp, :catch_failures => true)
      # Run it twice to test for idempotency
      apply_manifest_on('rpm', pp, :catch_changes  => true)
    elsif install_method == 'tarball'
      apply_manifest_on('tarball', pp, :catch_failures => true)
      # Run it twice to test for idempotency
      apply_manifest_on('tarball', pp, :catch_changes  => true)
    else
      fail("Unexpected install method: #{install_method}")
    end
  end
end

# Shared function that handles generic validations
# These should be common for all odl class param combos
def generic_validations()
  # TODO: It'd be nice to do this independently of install dir name
  describe file('/opt/opendaylight-0.2.2/') do
    it { should be_directory }
    it { should be_owned_by 'odl' }
    it { should be_grouped_into 'odl' }
    it { should be_mode '775' }
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

# Shared function for validations related to the Karaf config file
def karaf_config_validations(options = {})
  # NB: These param defaults should match the ones used by the opendaylight
  #   class, which are defined in opendaylight::params
  # TODO: Remove this possible source of bugs^^
  extra_features = options.fetch(:extra_features, [])
  default_features = options.fetch(:default_features, ['config', 'standard', 'region',
                                  'package', 'kar', 'ssh', 'management'])

  # Create one list of all of the features
  features = default_features + extra_features

  # TODO: It'd be nice to do this independently of install dir name
  describe file('/opt/opendaylight-0.2.2/etc/org.apache.karaf.features.cfg') do
    it { should be_file }
    it { should be_owned_by 'odl' }
    it { should be_grouped_into 'odl' }
    it { should be_mode '775' }
    its(:content) { should match /^featuresBoot=#{features.join(",")}/ }
  end
end

# Shared function that handles validations specific to RPM-type installs
def rpm_validations()
  describe yumrepo('opendaylight') do
    it { should exist }
    it { should be_enabled }
  end

  describe package('opendaylight') do
    it { should be_installed }
  end
end
