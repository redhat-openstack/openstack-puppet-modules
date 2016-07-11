require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'
require 'pry'

run_puppet_install_helper

# Xenial install is in /opt/puppetlabs

def example_manifest(name, path = '../examples')
  test_dir = File.expand_path File.join File.dirname(__FILE__), path
  manifest = File.join test_dir, name
  File.read manifest
end

debug = !ENV['BEAKER_debug'].nil?
root = parse_for_moduleroot Dir.pwd
host_manifest = example_manifest('pacemaker/host.pp', '../examples')
setup_manifest = example_manifest('pacemaker/setup.pp', '../examples')

RSpec.configure do |c|
  c.formatter = :documentation
  c.before :suite do
    hosts.each do |host|
      # https://tickets.puppetlabs.com/browse/BKR-821
      on host, '[ ! -f /opt/puppetlabs/bin/puppet ] || ln -s /opt/puppetlabs/bin/puppet /usr/bin/puppet'
      copy_module_to(host, source: root, module_name: 'pacemaker')
      on host, puppet('module', 'install', 'puppetlabs-stdlib')

      install_package host, 'git'
      shell 'test -d /etc/puppet/modules/corosync || git clone git://github.com/voxpupuli/puppet-corosync.git /etc/puppet/modules/corosync'

      apply_manifest(host_manifest, debug: true, catch_failures: true)
      apply_manifest(setup_manifest, debug: true, catch_failures: true)
    end
  end
end

shared_examples_for 'manifest' do |pp|
  raise 'No manifest to apply!' unless pp

  it 'should apply with no errors' do
    apply_manifest(pp, debug: debug, catch_failures: true)
  end

  it 'should apply a second time without changes', :skip_pup_5016 do
    apply_manifest(pp, debug: debug, catch_changes: true)
  end
end
