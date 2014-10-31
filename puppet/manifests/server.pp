# Puppet templating module by James
# Copyright (C) 2012-2013+ James Shubin
# Written by James Shubin <james@shubin.ca>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# NOTE: having a puppet::server module doesn't conflict with any bootstrap
# problems, because by default, puppet can run this module, and after that
# a poorly or simply configured puppet server can then use this module to
# properly configure additional functionality such as exported resources,
# proper authentication, etc...

class puppet::server(
	$pluginsync = true,		# do we want to enable pluginsync?
	$storeconfigs = false,		# do we want to enable storeconfigs?
	$autosign = [],			# autosign the following patterns
	$allow_duplicate_certs = false,	# allow duplicate certs
	$start = true,
	$repo = true,			# include repo's automatically ?
	$shorewall = false,
	$zone = 'net',			# TODO: allow for a list of zones
	# NOTE: this particular $allow is also used in fileserver.conf
	$allow = 'all'			# TODO: allow for a list of ip's per zone
) {
	if $repo {
		include puppet::params::repo
	}

	include puppet::params::package
	$package_server = $puppet::params::package::server

	class { 'puppet::common':
		repo => $repo,
		start => $start,
	}

	$FW = '$FW'			# make using $FW in shorewall easier

	$server = true

	include puppet::params::path
	$valid_modulespath = $puppet::params::path::modules
	$valid_hierapath = $puppet::params::path::hiera
	$valid_hieradatapath = $puppet::params::path::hieradata
	$valid_filespath = $puppet::params::path::files

	$valid_pluginsync = $pluginsync ? {
		false => 'false',
		default => 'true',
	}

	$valid_storeconfigs = $storeconfigs ? {
		true => 'true',
		default => 'false',
	}

	if $storeconfigs {
		# NOTE: this assumes puppetdb runs on the same server as puppet.
		# for now this is fine, in the future it might be beneficial to split them up.
		# XXX: for some reason, using localhost didn't work... XXX test this again in the future...
		class { 'puppet::puppetdb':
			repo => $repo,
			servername => "${hostname}",	# XXX: fqdn? XXX ?
		}
	}

	# XXX: because of http://projects.puppetlabs.com/issues/16686
	if versioncmp($puppetversion, '3.0.0') {
		$puppet_3_broken = true
	} else {
		$puppet_3_broken = false
	}

	# to address: https://puppetlabs.com/security/cve/cve-2012-3408/
	# XXX: update to version this is fixed in: http://projects.puppetlabs.com/issues/16686
	if versioncmp($puppetversion, '3.0.0') {
		$puppet_3 = true
	} else {
		$puppet_3 = false
	}

	package { "${package_server}":
		ensure => present,
		before => File['/etc/puppet/'],
		require => $repo ? {
			false => undef,
			default => Class['puppet::params::repo'],
		},
	}

	# ensure a file exists or we'll get a warning (apparently, empty is ok)
	exec { "/bin/touch ${valid_hierapath}":
		creates => "${valid_hierapath}",
		logoutput => on_failure,
		before => Service['puppetmaster'],
		require => Package["${package_server}"],
	}

	service { 'puppetmaster':
		enable => true,			# start on boot
		ensure => running,		# ensure it stays running
		hasstatus => true,		# use status command to monitor
		hasrestart => true,		# use restart, not start; stop
		require => Package["${package_server}"],
	}

	# ensure path exists or we'll get a warning
	exec { "/bin/mkdir -p ${valid_filespath}":
		creates => "${valid_filespath}",
		logoutput => on_failure,
		before => File['/etc/puppet/fileserver.conf'],
		require => Package["${package_server}"],
	}

	file { '/etc/puppet/fileserver.conf':
		content => template('puppet/fileserver.conf.erb'),
		owner => root,
		group => root,
		mode => 644,		# u=rw,go=r
		ensure => present,
		notify => Service['puppetmaster'],
	}

	file { '/etc/puppet/puppet.conf':
		content => template('puppet/puppet.conf.erb'),
		owner => root,
		group => root,
		mode => 644,		# u=rw,go=r
		ensure => present,
		notify => [Service['puppetmaster'], Service['puppet']],
	}

	file { '/etc/puppet/autosign.conf':
		content => template('puppet/autosign.conf.erb'),
		owner => root,
		group => root,
		mode => 644,		# u=rw,go=r
		ensure => present,
		notify => Service['puppetmaster'],
	}

	exec { "/bin/mkdir -p ${valid_hieradatapath}":
		creates => "${valid_hieradatapath}",
		logoutput => on_failure,
		require => File['/etc/puppet/'],	# TODO: parent dir instead ?
	}

	# create a directory for hiera data storage
	# conflicts with $::puppet::deploy
	#file { "${valid_hieradata}":		# /etc/puppet/hieradata/
	#	ensure => directory,		# make sure this is a directory
	#	recurse => false,
	#	purge => false,
	#	force => false,
	#	owner => root,
	#	group => root,
	#	mode => 644,
	#	require => File['/etc/puppet/puppet.conf'],
	#}

	if $shorewall {
		if $allow == 'all' or "${allow}" == '' {
			$net = "${zone}"
		} else {
			$net = is_array($allow) ? {
				true => sprintf("${zone}:%s", join($allow, ',')),
				default => "${zone}:${allow}",
			}
		}
		####################################################################
		#ACTION      SOURCE DEST                PROTO DEST  SOURCE  ORIGINAL
		#                                             PORT  PORT(S) DEST
		shorewall::rule { 'puppet-server': rule => "
		Puppet/ACCEPT    ${net}    $FW
		", comment => 'Allow incoming requests to puppet server.'}
	}
}

# vim: ts=8
