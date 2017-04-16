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

class puppet::vardir {	# module vardir snippet (slightly different for puppet)

	if "${::puppet_vardirtmp}" == '' {
		fail('Fact: $puppet_vardirtmp is missing!')
	}

	$tmp = sprintf("%s/", regsubst($::puppet_vardirtmp, '\/$', ''))
	# base directory where puppet modules can work and namespace in
	file { "${tmp}":
		ensure => directory,	# make sure this is a directory
		recurse => false,	# don't recurse into directory
		purge => true,		# purge all unmanaged files
		force => true,		# also purge subdirs and links
		owner => root,
		group => nobody,
		mode => 600,
		backup => false,	# don't backup to filebucket
		#before => File["${module_vardir}"],	# redundant
		#require => Package['puppet'],	# the package should point here
	}
	$module_vardir = sprintf("%s/puppet/", regsubst($tmp, '\/$', ''))
	# NOTE: puppet specific storage space not needed at the moment...
	#file { "${module_vardir}":		# /var/lib/puppet/tmp/puppet/
	#	ensure => directory,		# make sure this is a directory
	#	recurse => true,		# recursively manage directory
	#	purge => true,			# purge all unmanaged files
	#	force => true,			# also purge subdirs and links
	#	owner => root, group => nobody, mode => 600, backup => false,
	#	require => File["${tmp}"],	# File['/var/lib/puppet/tmp/']
	#}
}

# vim: ts=8
