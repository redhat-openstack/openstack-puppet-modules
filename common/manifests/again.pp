# Run puppet again if notified to do so
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

class common::again {

	include common::vardir

	#$vardir = $::common::vardir::module_vardir	# with trailing slash
	$vardir = regsubst($::common::vardir::module_vardir, '\/$', '')

	# store 'again' specific code in a separate directory
	file { "${vardir}/again/":
		ensure => directory,	# make sure this is a directory
		recurse => true,	# don't recurse into directory
		purge => true,		# don't purge unmanaged files
		force => true,		# don't purge subdirs and links
		require => File["${vardir}/"],
	}

	file { "${vardir}/again/again.py":
		# NOTE: this is actually templated, but no templating
		# is actually being used. This gives us the option to
		# pass in some variables if we decide we would like a
		# way to get values in other than via command line...
		# we could pass in some environ data or other data...
		content => template('common/again/again.py.erb'),
		owner => root,
		group => root,
		mode => 754,	# if you're not root, you can't run it!
		ensure => present,
		require => File["${vardir}/again/"],
	}

	# notify this command whenever you want to trigger another puppet run!
	exec { 'again':
		command => "${vardir}/again/again.py",
		logoutput => on_failure,
		refreshonly => true,	# run whenever someone requests it!
		require => File["${vardir}/again/again.py"],
	}
}

## NOTE: splitting this into a separate file didn't work properly in this module
#define common::again::delta(
#	$delta = 0,
#	# start timer counting now! (default is to start when puppet finishes!)
#	$start_timer_now = false
#) {
#	include common::vardir
#	include common::again

#	#$vardir = $::common::vardir::module_vardir	# with trailing slash
#	$vardir = regsubst($::common::vardir::module_vardir, '\/$', '')

#	$valid_start_timer_now = $start_timer_now ? {
#		true => '--start-timer-now',
#		default => '',
#	}

#	$arglist = ["--delta ${delta}", "${valid_start_timer_now}"]
#	$args = join(delete($arglist, ''), ' ')

#	# notify this command whenever you want to trigger another puppet run!
#	exec { "again-delta-${name}":
#		command => "${vardir}/again/again.py ${args}",
#		logoutput => on_failure,
#		refreshonly => true,	# run whenever someone requests it!
#		require => File["${vardir}/again/again.py"],
#	}
#}

# vim: ts=8
