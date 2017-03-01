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

# TODO: could we use frag { } to build puppet.conf on the server?
# maybe this is a bad idea to require puppet for puppet

# TODO: this module could probably be cleaned up a bit more...
# it's a bit messy because it's so old!

# XXX: if you want to recursively set a mode for a directory, but you want to
# set g+rs (setgid) for a directory, using recurse => true, this causes the
# files to gain setgid too, which is a bug security risk!
# see: http://projects.puppetlabs.com/issues/20001

# NOTE: when you push code/files to your server, if you use rsync, do use the
# --no-owner and --no-group options to avoid forcing 1000:1000 or other weird
# user:group priviledges on the destination, which can cause puppet to break!
# it is also very useful to add in --no-perms if you are transferring with -a

# vim: ts=8
