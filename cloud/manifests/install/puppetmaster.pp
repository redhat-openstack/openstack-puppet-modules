#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: cloud::install::puppetmaster
#
# Configure the puppet master on the install-server
#
# == Parameters:
#
#  [*puppetmaster_package_name*]
#    (optional) Name of the puppetmaster package name
#    Default: cloud::params::puppetmaster_package_name
#
#  [*puppetmaster_service_name*]
#    (optional) Name of the puppetmaster service name
#    Default: cloud::params::puppetmaster_service_name
#
#  [*main_configuration*]
#    (optional) Hash of ini settings to set in the main section of the configuration
#    Default: {}
#
#  [*agent_configuration*]
#    (optional) Hash of ini settings to set in the agent section of the configuration
#    Default: {}
#
#  [*master_configuration*]
#    (optional) Hash of ini settings to set in the master section of the configuration
#    Default: {}
#
#  [*puppetmaster_vhost_configuration*]
#    (optional) Hash of vhost configuration for the puppetmaster vhost
#    Default: {}
#
#  [*puppetconf_path*]
#    (optional) Path to the puppet master configuration file
#    Default: /etc/puppet/puppet.conf
#
#  [*puppetdb_enable*]
#    (optional) Whether the configuration for puppetdb should be enabled
#    Default: true
#
#  [*autosign_domains*]
#    (optional) Array of domain origin to be auto signed
#    Default: empty
#
class cloud::install::puppetmaster (
  $puppetmaster_package_name        = $cloud::params::puppetmaster_package_name,
  $puppetmaster_service_name        = $cloud::params::puppetmaster_service_name,
  $main_configuration               = {},
  $agent_configuration              = {},
  $master_configuration             = {},
  $puppetmaster_vhost_configuration = {},
  $puppetconf_path                  = '/etc/puppet/puppet.conf',
  $puppetdb_enable                  = true,
  $autosign_domains                 = [],
) inherits cloud::params {

  package { $puppetmaster_package_name :
    ensure => present,
    before => File['/usr/share/puppet/rack'],
  } ->
  service { $puppetmaster_service_name :
    ensure     => stopped,
    hasstatus  => true,
    hasrestart => true,
  } ->
  exec { "puppet cert generate ${::fqdn}":
    unless => "stat /var/lib/puppet/ssl/certs/${::fqdn}.pem",
    path   => ['/usr/bin', '/bin']
  }

  # TODO (spredzy): Dirty hack
  # to have the package in the catalog
  # so puppetlabs/apache won't try to install it
  # and fail since it's not present on rhel7
  if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == 7 {
    package { 'mod_passenger' :
      ensure => absent,
      before => Class['apache'],
    }
  }

  # Create the proper passenger configuration
  # Per https://docs.puppetlabs.com/guides/passenger.html
  file {
    '/usr/share/puppet/rack' :
      ensure => directory;
    '/usr/share/puppet/rack/puppetmasterd' :
      ensure => directory;
    '/usr/share/puppet/rack/puppetmasterd/public' :
      ensure => directory;
    '/usr/share/puppet/rack/puppetmasterd/tmp' :
      ensure => directory;
    '/usr/share/puppet/rack/puppetmasterd/config.ru' :
      ensure => link,
      owner  => 'puppet',
      group  => 'puppet',
      target => '/usr/share/puppet/ext/rack/config.ru';
  }

  class { 'hiera' :
    datadir   => '/etc/puppet/data',
    hierarchy => [
      '%{::type}/%{::fqdn}',
      '%{::type}/common',
      'common',
    ]
  }

  if $puppetdb_enable {
    Class['::puppetdb::master::config'] ~> Service['httpd']
    include ::puppetdb::master::config
  }

  include ::apache
  create_resources('apache::vhost', $puppetmaster_vhost_configuration, { 'require' => "Exec[puppet cert generate ${::fqdn}]" })

  create_resources('ini_setting', $main_configuration, { 'section' => 'main', 'path' => $puppetconf_path, 'require' => "Package[${puppetmaster_package_name}]", 'notify' => 'Service[httpd]' })
  create_resources('ini_setting', $agent_configuration, { 'section' => 'agent', 'path' => $puppetconf_path, 'require' => "Package[${puppetmaster_package_name}]", 'notify' => 'Service[httpd]' })
  create_resources('ini_setting', $master_configuration, { 'section' => 'master', 'path' => $puppetconf_path, 'require' => "Package[${puppetmaster_package_name}]", 'notify' => 'Service[httpd]' })

  file { '/etc/puppet/autosign.conf' :
    ensure  => present,
    owner   => 'puppet',
    group   => 'puppet',
    content => template('cloud/installserver/autosign.conf.erb'),
    require => Package[$puppetmaster_package_name],
    notify  => Service['httpd'],
  }

}
