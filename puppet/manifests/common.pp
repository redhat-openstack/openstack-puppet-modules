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

# common aspects to puppet::client and puppet::server (which is the client too)
class puppet::common(
	$repo = true,
	$start = true				# start puppet client ?
) {
	include puppet::vardir
	include puppet::facter
	include puppet::params::package
	$package_augeas = $puppet::params::package::augeas
	if $repo {
		include puppet::params::repo
	}

	# this is here so that the puppet package references the vardirtmp dir,
	# and not the other way around. this lets puppet::vardir be used alone!
	$tmp = sprintf("%s/", regsubst($::puppet::vardir::puppet_vardirtmp, '\/$', ''))

	$ensure = $start ? {
		false => undef,		# we don't want ensure => stopped
		default => running,
	}

	# create stages for all modules to be able to use
	stage { 'first':
		before => Stage['main'],
	}
	stage { 'last':
		require => Stage['main'],
	}

	# these are needed for the augeas{} type
	package { $package_augeas:
		ensure => present,
		require => $repo ? {
			false => undef,
			default => Class['puppet::params::repo'],
		},
	}

	# this package comes from the repo, the repo dependency is above...
	package { 'puppet':
		ensure => present,
		before => [
			File['/etc/puppet/'],
			File["${tmp}"],	# this points to inside puppet::vardir
		],
		require => Package[$package_augeas],
	}

	# TODO: is rubygem-rdoc equivalent ?
	#package { 'ruby-rdoc':		# provide 'RDoc::usage' for puppet help
	#	ensure => present,
	#	require => Package['puppet'],	# install only if puppet is used
	#}

	# TODO: enable this if we ever use the gem provider...
	# NOTE: for building closed systems, hopefully gem can install offline!
	#package { 'rubygems':		# provide package provider => 'gem'
	#	ensure => present,
	#	require => Package['puppet'],	# install only if puppet is used
	#}

	file { '/etc/puppet/':
		ensure => directory,		# make sure this is a directory
		recurse => true,		# propagate permissions
		purge => false,			# don't remove unmanaged things
		force => false,
		owner => root,
		group => root,
		#mode => 'u=rw,g=rs,o=r',	# TODO: what is the ideal mode?
		mode => 644,			# XXX: temporary until: http://projects.puppetlabs.com/issues/20001
	}

	service { 'puppet':
		enable => $start,		# start on boot
		ensure => $ensure,		# ensures nothing if undef
		hasstatus => true,		# use status command to monitor
		hasrestart => true,		# use restart, not start; stop
		require => Package['puppet'],
	}

	file { '/etc/puppet/auth.conf':
		# XXX: Error: /Stage[main]/Puppet::Common/File[/etc/puppet/auth.conf]: Could not evaluate: uninitialized constant Puppet::FileSystem::File Could not retrieve file metadata for puppet:///modules/puppet/auth.conf: uninitialized constant Puppet::FileSystem::File
		#source => 'puppet:///modules/puppet/auth.conf',
		content => template('puppet/auth.conf.erb'),
		owner => root,
		group => root,
		mode => 644,		# u=rw,go=r
		ensure => present,
		notify => Service['puppet'],
	}

	# scratch directory for various packages to work and namespace in
	file { '/root/puppet/':
		ensure => directory,		# make sure this is a directory
		recurse => false,		# don't recurse into directory
		purge => true,			# purge all unmanaged files
		force => true,			# also purge subdirs and links
		owner => root,
		group => nobody,
		mode => 600,
		backup => false,		# don't backup to filebucket
		require => Package['puppet'],
	}
}

# vim: ts=8
