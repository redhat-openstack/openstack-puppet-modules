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

require 'facter'

# find the module_vardir
dir = Facter.value('puppet_vardirtmp')		# nil if missing
if dir.nil?					# let puppet decide if present!
	dir = Facter.value('puppet_vardir')
	if dir.nil?
		var = nil
	else
		var = dir.gsub(/\/$/, '')+'/'+'tmp/'	# ensure trailing slash
	end
else
	var = dir.gsub(/\/$/, '')+'/'
end

if var.nil?
	# if we can't get a valid vardirtmp, then we can't continue
	module_vardir = nil
	counterdir = nil
	counter_simple = nil
else
	module_vardir = var+'common/'
	counterdir = module_vardir+'counter/'
	counter_simple = counterdir+'simple'
end

# NOTE: module specific mkdirs, needed to ensure there is no blocking/deadlock!
if not(var.nil?) and not File.directory?(var)
	Dir::mkdir(var)
end

if not(module_vardir.nil?) and not File.directory?(module_vardir)
	Dir::mkdir(module_vardir)
end

if not(counterdir.nil?) and not File.directory?(counterdir)
	Dir::mkdir(counterdir)
end

value = 0	# default value to use if file doesn't exist
# create the fact if the counter file contains a valid int, or if it's empty: 0
if not(counter_simple.nil?) and File.exist?(counter_simple)
	# an empty file will output a value of 0 with this idiomatic line...
	value = File.open(counter_simple, 'r').read.strip.to_i	# read into int
end
Facter.add('common_counter_simple') do
	#confine :operatingsystem => %w{CentOS, RedHat, Fedora}
	setcode {
		value
	}
end

# vim: ts=8
