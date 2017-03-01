# Increment an ID so that it is unique to each puppet run.
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

class common::counter {

	include common::vardir

	#$vardir = $::common::vardir::module_vardir	# with trailing slash
	$vardir = regsubst($::common::vardir::module_vardir, '\/$', '')

	# store 'counter' in a separate directory
	file { "${vardir}/counter/":
		ensure => directory,	# make sure this is a directory
		recurse => true,	# don't recurse into directory
		purge => true,		# don't purge unmanaged files
		force => true,		# don't purge subdirs and links
		require => File["${vardir}/"],
	}

	file { "${vardir}/counter/increment.py":
		# NOTE: this is actually templated, but no templating
		# is actually being used. This gives us the option to
		# pass in some variables if we decide we would like a
		# way to get values in other than via command line...
		# we could pass in some environ data or other data...
		content => template('common/counter/increment.py.erb'),
		owner => root,
		group => root,
		mode => 755,
		ensure => present,
		require => File["${vardir}/counter/"],
	}

	# NOTE: this is a simple counter. it is 'simple' because it is probably
	# possible to build more complex counters that can ensure that only one
	# increment happens per puppet run if multiple puppets run in parallel!
	# in other words: this simple counter doesn't do any file locking stuff
	file { "${vardir}/counter/simple":
		owner => root,
		group => root,
		mode => 644,
		ensure => present,
		require => File["${vardir}/counter/"],
	}

	# this command silently increments the counter without displaying logs!
	exec { 'counter':
		# echo an error message and be false, if the incrementing fails
		command => '/bin/echo "common::counter failed" && /bin/false',
		# NOTE: this 'unless' is actually _NOT_ idempotent as is normal
		# it should always return true, unless there's an error running
		unless => "${vardir}/counter/increment.py '${vardir}/counter/simple'",
		logoutput => on_failure,
		require => [
			File["${vardir}/counter/increment.py"],
			File["${vardir}/counter/simple"],
		],
	}
}

# vim: ts=8
