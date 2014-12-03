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

class puppet::deploy(		# copy files into the /etc/puppet/ directory...
	# these parameters are source paths
	$path = '',		# either specify this, or, each individually...
	$manifests = '',
	$hiera = '',		# hiera.yaml
	$hieradata = '',	# hieradata/ folder
	$modules = '',
	$files = '',
	$backup = true,		# optionally save anything we might squash...
) {
	include puppet::params::package
	$package_server = $puppet::params::package::server

	# copy over the puppet code from the deploy path to the main puppet dir
	# TODO: add the correct selinux contexts where appropriate

	$valid_backup = $backup ? {
		false => false,
		default => true,
	}

	# these are source paths
	$source_manifests = $manifests ? {			# source!
		'' => $path ? {
			'' => '',				# nothing
			default => sprintf("%s/manifests/", regsubst($path, '\/$', '')),
		},
		default => $manifests,	# if it's something, then use that.
	}

	$source_hiera = $hiera ? {
		'' => $path ? {
			'' => '',
			default => sprintf("%s/hiera.yaml", regsubst($path, '\/$', '')),
		},
		default => $hiera,
	}

	$source_hieradata = $hieradata ? {
		'' => $path ? {
			'' => '',
			default => sprintf("%s/hieradata/", regsubst($path, '\/$', '')),
		},
		default => $hieradata,
	}

	$source_modules = $modules ? {
		'' => $path ? {
			'' => '',
			default => sprintf("%s/modules/", regsubst($path, '\/$', '')),
		},
		default => $modules,
	}

	$source_files = $files ? {
		'' => $path ? {
			'' => '',
			default => sprintf("%s/files/", regsubst($path, '\/$', '')),
		},
		default => $files,
	}

	# these are destination paths
	include puppet::params::path
	$dest_manifests = $puppet::params::path::manifests
	$dest_hiera = $puppet::params::path::hiera
	$dest_hieradata = $puppet::params::path::hieradata
	$dest_modules = $puppet::params::path::modules
	$dest_files = $puppet::params::path::files

	$before = "${source_manifests}" ? {
		'' => Service['puppetmaster'],
		default => [
			File["${dest_manifests}"],
			Service['puppetmaster'],
		],
	}
	#$onlyif_files = "/usr/bin/test -e ${path}files/"
	#$onlyif_modules = "/usr/bin/test -e ${path}modules/"
	#$onlyif_hieradata = "/usr/bin/test -e ${path}hieradata/"
	#$onlyif_hiera = "/usr/bin/test -e ${path}hiera.yaml"

	# each file/directory should run before manifests because if it is the
	# first time copying files, then this will ensure everything is copied
	# over before puppet could possibly run something useful without deps.
	if "${source_files}" != '' {
		file { "${dest_files}":
			source => $source_files,		# copy files over
			ensure => directory,
			recurse => true,
			purge => true,
			force => true,
			owner => root,
			group => root,
			#mode => 'u=rw,g=rs,o=r',	# TODO: what is the ideal mode?
			#mode => 'u=rw,g=r,o=r',	# XXX: this breaks things!
			mode => 644,			# XXX: temporary until: http://projects.puppetlabs.com/issues/20001
			backup => $valid_backup,
			notify => Service['puppetmaster'],	# notice the pp changes
			before => $before,			# copy before server up
			require => Package["${package_server}"],	# need root directories
		}
		# XXX: temporary until: http://projects.puppetlabs.com/issues/20001
		exec { "/bin/chmod g+s ${dest_files}":
			onlyif => "/usr/bin/test -d '${dest_files}' && /usr/bin/test ! -g '${dest_files}'",
			require => File["${dest_files}"],
		}
	}
	#exec { 'rsync-files':
	#	command => "/usr/bin/rsync -a --delete ${path}files/ /var/lib/puppet/files/",
	#	creates => '/var/lib/puppet/files/',
	#	onlyif => $onlyif_files,
	#	notify => Service['puppetmaster'],
	#	before => Service['puppetmaster'],
	#	require => Package["${package_server}"],
	#}

	if "${source_modules}" != '' {
		file { "${dest_modules}":
			source => $source_modules,		# copy files over
			ignore => '.git',	# extra copying is superfluous!
			ensure => directory,
			recurse => true,
			purge => true,
			force => true,
			owner => root,
			group => root,
			#mode => 'u=rw,g=rs,o=r',	# TODO: what is the ideal mode?
			#mode => 'u=rw,g=r,o=r',	# XXX: this breaks things!
			mode => 644,			# XXX: temporary until: http://projects.puppetlabs.com/issues/20001
			backup => $valid_backup,
			notify => Service['puppetmaster'],
			before => $before,
			require => Package["${package_server}"],
		}
		# XXX: temporary until: http://projects.puppetlabs.com/issues/20001
		exec { "/bin/chmod g+s ${dest_modules}":
			onlyif => "/usr/bin/test -d '${dest_modules}' && /usr/bin/test ! -g '${dest_modules}'",
			require => File["${dest_modules}"],
		}
	}
	#exec { 'rsync-modules':
	#	command => "/usr/bin/rsync -a --delete ${path}modules/ /var/lib/puppet/modules/",
	#	creates => '/var/lib/puppet/modules/',
	#	onlyif => $onlyif_modules,
	#	notify => Service['puppetmaster'],
	#	before => Service['puppetmaster'],
	#	require => Package["${package_server}"],
	#}

	if "${source_hieradata}" != '' {
		file { "${dest_hieradata}":
			source => $source_hieradata,		# copy files over
			ensure => directory,
			recurse => true,
			purge => true,
			force => true,
			owner => root,
			group => root,
			#mode => 'u=rw,g=rs,o=r',	# TODO: what is the ideal mode?
			#mode => 'u=rw,g=r,o=r',	# XXX: this breaks things!
			mode => 644,			# XXX: temporary until: http://projects.puppetlabs.com/issues/20001
			backup => $valid_backup,
			notify => Service['puppetmaster'],
			before => $before,
			require => Package["${package_server}"],
		}
		# XXX: temporary until: http://projects.puppetlabs.com/issues/20001
		exec { "/bin/chmod g+s ${dest_hieradata}":
			onlyif => "/usr/bin/test -d '${dest_hieradata}' && /usr/bin/test ! -g '${dest_hieradata}'",
			require => File["${dest_hieradata}"],
		}
	}
	#exec { 'rsync-hieradata':
	#	command => "/usr/bin/rsync -a --delete ${path}hieradata/ /etc/puppet/hieradata/",
	#	creates => '/etc/puppet/hieradata/globals.yaml',
	#	onlyif => $onlyif_hieradata,
	#	notify => Service['puppetmaster'],
	#	before => Service['puppetmaster'],
	#	require => Package["${package_server}"],
	#}

	# XXX: had to do restorecon -v /etc/puppet/hiera.yaml to make selinux not break!
	if "${source_hiera}" != '' {
		file { "${dest_hiera}":
			source => $source_hiera,			# copy file over
			ensure => present,
			force => true,
			owner => root,
			group => root,
			mode => 'u=rw,g=r,o=r',			# TODO: what is the ideal mode?
			backup => $valid_backup,
			# FIXME: notify because of:
			# http://projects.puppetlabs.com/issues/show/19343
			notify => Service['puppetmaster'],
			before => $before,
			require => Package["${package_server}"],
		}
	}
	#exec { 'rsync-hiera':
	#	command => "/usr/bin/rsync -a ${path}hiera.yaml /etc/puppet/hiera.yaml",
	#	creates => '/etc/puppet/hiera.yaml',
	#	onlyif => $onlyif_hiera,
	#	notify => Service['puppetmaster'],
	#	before => Service['puppetmaster'],
	#	require => Package["${package_server}"],
	#}

	# don't install manifests until deps are present! execute this one last
	if "${source_manifests}" != '' {
		file { "${dest_manifests}":
			source => $source_manifests,		# copy files over
			ensure => directory,
			recurse => true,
			purge => true,
			force => true,
			owner => root,
			group => root,
			#mode => 'u=rw,g=rs,o=r',	# TODO: what is the ideal mode?
			#mode => 'u=rw,g=r,o=r',	# XXX: this breaks things!
			mode => 644,			# XXX: temporary until: http://projects.puppetlabs.com/issues/20001
			backup => $valid_backup,
			notify => Service['puppetmaster'],	# notice the pp changes
			before => Service['puppetmaster'],	# copy before server up
			require => Package["${package_server}"],	# need root directories
		}
		# XXX: temporary until: http://projects.puppetlabs.com/issues/20001
		exec { "/bin/chmod g+s ${dest_manifests}":
			onlyif => "/usr/bin/test -d '${dest_manifests}' && /usr/bin/test ! -g '${dest_manifests}'",
			require => File["${dest_manifests}"],
		}
	}
	#exec { 'rsync-manifests':
	#	command => "/usr/bin/rsync -a --delete ${path}manifests/ /etc/puppet/manifests/",
	#	creates => '/etc/puppet/manifests/site.pp',
	#
	#	onlyif => [
	#		$onlyif_files,
	#		$onlyif_modules,
	#		$onlyif_hieradata,
	#		$onlyif_hiera,
	#		"/usr/bin/test -e ${path}manifests/",
	#	],
	#	notify => Service['puppetmaster'],
	#	before => Service['puppetmaster'],
	#	require => [
	#		Exec['rsync-files'],
	#		Exec['rsync-modules'],
	#		Exec['rsync-hieradata'],
	#		Exec['rsync-hiera'],
	#		Package["${package_server}"],
	#	],
	#}
}

# vim: ts=8
