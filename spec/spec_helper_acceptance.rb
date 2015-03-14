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

# NB: There are a large number of helper functions used in these tests.
# They make this code much more friendly, but may need to be referenced.
# The serverspec helpers (`should`, `be_running`...) are documented here:
#   http://serverspec.org/resource_types.html

def install_odl(options = {})
  # NB: These param defaults should match the ones used by the opendaylight
  #   class, which are defined in opendaylight::params
  # TODO: Remove this possible source of bugs^^
  # Extract params if given, defaulting to odl class defaults if not
  # Default install method is passed via environment var, set in Rakefile
  install_method = options.fetch(:install_method, ENV['INSTALL_METHOD'])
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

    # Apply our Puppet manifest on the Beaker host
    apply_manifest(pp, :catch_failures => true)

    # The tarball extract isn't idempotent, can't do this check
    # See: https://github.com/dfarrell07/puppet-opendaylight/issues/45#issuecomment-78135725
    if install_method != 'tarball'
      # Run it twice to test for idempotency
      apply_manifest(pp, :catch_changes  => true)
    end
  end
end

# Shared function that handles generic validations
# These should be common for all odl class param combos
def generic_validations()
  # Verify ODL's directory
  describe file('/opt/opendaylight/') do
    it { should be_directory }
    it { should be_owned_by 'odl' }
    it { should be_grouped_into 'odl' }
  end

  # Verify ODL systemd .service file
  describe file('/usr/lib/systemd/system/opendaylight.service') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode '644' }
  end

  # Verify ODL's systemd service
  describe service('opendaylight') do
    it { should be_enabled }
    it { should be_enabled.with_level(3) }
    it { should be_running }
  end

  # Creation handled by RPM, or Puppet during tarball installs
  describe user('odl') do
    it { should exist }
    it { should belong_to_group 'odl' }
    # NB: This really shouldn't have a slash at the end!
    #     The home dir set by the RPM is `/opt/opendaylight`.
    #     Since we use the trailing slash elsewhere else, this
    #     may look like a style issue. It isn't! It will make
    #     Beaker tests fail if it ends with a `/`. A future
    #     version of the ODL RPM may change this.
    it { should have_home_directory '/opt/opendaylight' }
  end

  # Creation handled by RPM, or Puppet during tarball installs
  describe group('odl') do
    it { should exist }
  end

  # This should not be the odl user's home dir
  describe file('/home/odl') do
    # Home dir shouldn't be created for odl user
    it { should_not be_directory }
  end

  # Java 7 should be installed
  describe package('java-1.7.0-openjdk') do
    it { should be_installed }
  end

  # OpenDaylight will appear as a Java process
  describe process('java') do
    it { should be_running }
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

  describe file('/opt/opendaylight/etc/org.apache.karaf.features.cfg') do
    it { should be_file }
    it { should be_owned_by 'odl' }
    it { should be_grouped_into 'odl' }
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

# Shared function that handles validations specific to tarball-type installs
def tarball_validations()
  describe yumrepo('opendaylight') do
    it { should_not exist }
    it { should_not be_enabled }
  end

  describe package('opendaylight') do
    it { should_not be_installed }
  end
end
