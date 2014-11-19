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

# NOTE: see ../again.pp for the delta code

# NOTE: splitting this into a separate file didn't work properly in this module
define common::again::delta(
	$delta = 0,
	# start timer counting now! (default is to start when puppet finishes!)
	$start_timer_now = false
) {
	include common::vardir
	include common::again

	#$vardir = $::common::vardir::module_vardir	# with trailing slash
	$vardir = regsubst($::common::vardir::module_vardir, '\/$', '')

	$valid_delta = inline_template('<%= [Fixnum, String].include?(@delta.class) ? @delta.to_i : 0 %>')

	$valid_start_timer_now = $start_timer_now ? {
		true => '--start-timer-now',
		default => '',
	}

	$arglist = ["--delta ${valid_delta}", "${valid_start_timer_now}"]
	$args = join(delete($arglist, ''), ' ')

	# notify this command whenever you want to trigger another puppet run!
	exec { "again-delta-${name}":
		command => "${vardir}/again/again.py ${args}",
		logoutput => on_failure,
		refreshonly => true,	# run whenever someone requests it!
		require => File["${vardir}/again/again.py"],
	}
}


# vim: ts=8
