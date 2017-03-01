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

class puppet::puppetdb(
	# NOTE: the connection details here are the locations that puppetmaster
	# uses to connect to the puppetdb service. By default, on the same host.
	$servername = 'localhost',
	$port = 8081,
	$repo = true
) {

	if $repo {
		include puppet::params::repo
	}

	package { 'puppetdb':
		ensure => present,
		require => $repo ? {
			false => undef,
			default => Class['puppet::params::repo'],
		},
	}

	# http://projects.puppetlabs.com/issues/23315
	$file = '/etc/puppetdb/conf.d/jetty.ini'
	$line = 'cipher-suites = TLS_RSA_WITH_AES_256_CBC_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_128_CBC_SHA256,TLS_RSA_WITH_AES_128_CBC_SHA,SSL_RSA_WITH_RC4_128_SHA,SSL_RSA_WITH_3DES_EDE_CBC_SHA,SSL_RSA_WITH_RC4_128_MD5'
	exec { "/bin/echo '${line}' >> '${file}'":
		logoutput => on_failure,
		onlyif => "/usr/bin/test -e '${file}'",
		unless => "/bin/grep -qFx '${line}' '${file}'",
		before => Service['puppetdb'],
		require => Package['puppetdb'],
	}

	# needed to start puppetmaster with certain routes.yaml files...
	package { 'puppetdb-terminus':
		ensure => present,
		before => Service['puppetmaster'],
	}

	file { '/etc/puppet/routes.yaml':
		# XXX: Error: /Stage[main]/Puppet::Puppetdb/File[/etc/puppet/routes.yaml]: Could not evaluate: uninitialized constant Puppet::FileSystem::File Could not retrieve file metadata for puppet:///modules/puppet/routes.yaml: uninitialized constant Puppet::FileSystem::File
		#source => 'puppet:///modules/puppet/routes.yaml',
		content => template('puppet/routes.yaml.erb'),
		owner => root,
		group => root,
		mode => 644,		# u=rw,go=r
		ensure => present,
		notify => [
			# FIXME: are either of these necessary ?
			Service['puppetdb'],
			Service['puppetmaster'],
		],
		require => [
			Package['puppetdb'],
			Package['puppetdb-terminus'],
		],
	}

	file { '/etc/puppet/puppetdb.conf':
		content => template('puppet/puppetdb.conf.erb'),
		owner => root,
		group => root,
		mode => 644,		# u=rw,go=r
		ensure => present,
		notify => [
			# FIXME: are either of these necessary ?
			Service['puppetdb'],
			Service['puppetmaster'],
		],
		require => Package['puppetdb'],
	}

	# it seems that puppetdb doesn't start without this ssl file created...
	exec { '/usr/sbin/puppetdb-ssl-setup':
		#creates => '/etc/puppetdb/ssl/keystore.jks',	# used to work
		creates => [
			'/etc/puppetdb/ssl/ca.pem',
			'/etc/puppetdb/ssl/public.pem',
			'/etc/puppetdb/ssl/private.pem',
		],
		logoutput => on_failure,
		before => Service['puppetdb'],
		require => [
			Package['puppetdb'],
			Service['puppetmaster'],	# attempt to help with:
			# https://groups.google.com/forum/?fromgroups=#!topic/puppet-users/yQr3eW6sM9g
			# http://serverfault.com/questions/400092/puppetdb-failed-to-submit-replace-facts-command
			# it seems the puppetmaster cert needs to get generated
			# before the puppetdb cert does for complicated reasons
		],
	}

	service { 'puppetdb':
		enable => true,			# start on boot
		ensure => running,		# ensure it stays running
		hasstatus => true,		# use status command to monitor
		hasrestart => true,		# use restart, not start; stop
		require => [
			File['/etc/puppet/routes.yaml'],
			File['/etc/puppet/puppetdb.conf'],
			# XXX: should this be here, should it be a 'before', or should it not be here at all ?
			# apparently, it doesn't matter which starts first...
			Service['puppetmaster'],
		],
	}
}

# vim: ts=8
