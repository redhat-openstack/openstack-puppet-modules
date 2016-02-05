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
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0] }
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
  default_features = options.fetch(:default_features,
    ['config', 'standard', 'region', 'package', 'kar', 'ssh', 'management'])
  odl_rest_port = options.fetch(:odl_rest_port, 8080)
  log_levels = options.fetch(:log_levels, {})
  enable_l3 = options.fetch(:enable_l3, 'no')

  # Build script for consumption by Puppet apply
  it 'should work idempotently with no errors' do
    pp = <<-EOS
    class { 'opendaylight':
      install_method => #{install_method},
      default_features => #{default_features},
      extra_features => #{extra_features},
      odl_rest_port=> #{odl_rest_port},
      enable_l3=> #{enable_l3},
      log_levels=> #{log_levels},
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

  # OpenDaylight will appear as a Java process
  describe process('java') do
    it { should be_running }
  end

  # Should contain Karaf features config file
  describe file('/opt/opendaylight/etc/org.apache.karaf.features.cfg') do
    it { should be_file }
    it { should be_owned_by 'odl' }
    it { should be_grouped_into 'odl' }
  end

  # Should contain ODL NB port config file
  describe file('/opt/opendaylight/etc/jetty.xml') do
    it { should be_file }
    it { should be_owned_by 'odl' }
    it { should be_grouped_into 'odl' }
  end

  # Should contain log level config file
  describe file('/opt/opendaylight/etc/org.ops4j.pax.logging.cfg') do
    it { should be_file }
    it { should be_owned_by 'odl' }
    it { should be_grouped_into 'odl' }
  end

  # Should contain ODL OVSDB L3 enable/disable config file
  describe file('/opt/opendaylight/etc/custom.properties') do
    it { should be_file }
    it { should be_owned_by 'odl' }
    it { should be_grouped_into 'odl' }
  end

  if ['centos-7', 'centos-7-docker', 'fedora-22'].include? ENV['RS_SET']
    # Validations for modern Red Hat family OSs

    # Verify ODL systemd .service file
    describe file('/usr/lib/systemd/system/opendaylight.service') do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode '644' }
    end

    # Java 8 should be installed
    describe package('java-1.8.0-openjdk') do
      it { should be_installed }
    end
  elsif ['ubuntu-1404', 'ubuntu-1404-docker'].include? ENV['RS_SET']
    # Ubuntu-specific validations

    # Verify ODL Upstart config file
    describe file('/etc/init/opendaylight.conf') do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode '644' }
    end

    # Java 7 should be installed
    describe package('openjdk-7-jdk') do
      it { should be_installed }
    end
  else
    fail("Unexpected RS_SET (host OS): #{ENV['RS_SET']}")
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

# Shared function for validations related to the ODL REST port config file
def port_config_validations(options = {})
  # NB: This param default should match the one used by the opendaylight
  #   class, which is defined in opendaylight::params
  # TODO: Remove this possible source of bugs^^
  odl_rest_port = options.fetch(:odl_rest_port, 8080)

  describe file('/opt/opendaylight/etc/jetty.xml') do
    it { should be_file }
    it { should be_owned_by 'odl' }
    it { should be_grouped_into 'odl' }
    its(:content) { should match /Property name="jetty.port" default="#{odl_rest_port}"/ }
  end
end

# Shared function for validations related to custom logging verbosity
def log_level_validations(options = {})
  # NB: This param default should match the one used by the opendaylight
  #   class, which is defined in opendaylight::params
  # TODO: Remove this possible source of bugs^^
  log_levels = options.fetch(:log_levels, {})

  if log_levels.empty?
    # Should contain log level config file
    describe file('/opt/opendaylight/etc/org.ops4j.pax.logging.cfg') do
      it { should be_file }
      it { should be_owned_by 'odl' }
      it { should be_grouped_into 'odl' }
    end
    # Should not contain custom log level config
    describe file('/opt/opendaylight/etc/org.ops4j.pax.logging.cfg') do
      it { should be_file }
      it { should be_owned_by 'odl' }
      it { should be_grouped_into 'odl' }
      its(:content) { should_not match /# Log level config added by puppet-opendaylight/ }
    end
  else
    # Should contain log level config file
    describe file('/opt/opendaylight/etc/org.ops4j.pax.logging.cfg') do
      it { should be_file }
      it { should be_owned_by 'odl' }
      it { should be_grouped_into 'odl' }
    end
    # Should not contain custom log level config
    describe file('/opt/opendaylight/etc/org.ops4j.pax.logging.cfg') do
      it { should be_file }
      it { should be_owned_by 'odl' }
      it { should be_grouped_into 'odl' }
      its(:content) { should match /# Log level config added by puppet-opendaylight/ }
    end
    # Verify each custom log level config entry
    log_levels.each_pair do |logger, level|
      describe file('/opt/opendaylight/etc/org.ops4j.pax.logging.cfg') do
        it { should be_file }
        it { should be_owned_by 'odl' }
        it { should be_grouped_into 'odl' }
        its(:content) { should match /^log4j.logger.#{logger} = #{level}/ }
      end
    end
  end
end

# Shared function for validations related to ODL OVSDB L3 config
def enable_l3_validations(options = {})
  # NB: This param default should match the one used by the opendaylight
  #   class, which is defined in opendaylight::params
  # TODO: Remove this possible source of bugs^^
  enable_l3 = options.fetch(:enable_l3, 'no')

  if [true, 'yes'].include? enable_l3
    # Confirm ODL OVSDB L3 is enabled
    describe file('/opt/opendaylight/etc/custom.properties') do
      it { should be_file }
      it { should be_owned_by 'odl' }
      it { should be_grouped_into 'odl' }
      its(:content) { should match /^ovsdb.l3.fwd.enabled=yes/ }
    end
  elsif [false, 'no'].include? enable_l3
    # Confirm ODL OVSDB L3 is disabled
    describe file('/opt/opendaylight/etc/custom.properties') do
      it { should be_file }
      it { should be_owned_by 'odl' }
      it { should be_grouped_into 'odl' }
      its(:content) { should match /^ovsdb.l3.fwd.enabled=no/ }
    end
  end
end

# Shared function that handles validations specific to RPM-type installs
def rpm_validations()
  describe yumrepo('opendaylight-4-testing') do
    it { should exist }
    it { should be_enabled }
  end

  describe package('opendaylight') do
    it { should be_installed }
  end
end

# Shared function that handles validations specific to tarball-type installs
def tarball_validations()
  describe package('opendaylight') do
    it { should_not be_installed }
  end

  # Repo checks break (not fail) when yum doesn't make sense (Ubuntu)
  if ['centos-7', 'fedora-22'].include? ENV['RS_SET']
    describe yumrepo('opendaylight-4-testing') do
      it { should_not exist }
      it { should_not be_enabled }
    end
  end
end
