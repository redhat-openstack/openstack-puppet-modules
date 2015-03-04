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

class puppet::params::repo::yum {

	$version = "${operatingsystemrelease}" ? {
		'6.0' => '6',
		#6.1 => '6.1',
		#6.2 => '6.2',
		#6.3 => '6.3',
		#6.4 => '6.4',
		'6.5' => '6',
		'7.0.1406' => '7',
		default => "${operatingsystemrelease}",
	}

	include ::yum

	yum::repos::repo { 'puppetlabs':
		baseurl => "https://yum.puppetlabs.com/el/${version}/products/x86_64/",
		enabled => true,
		gpgcheck => true,
		gpgkeys => [	# XXX: these should be files, not https:// links
			'https://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs',
			'https://yum.puppetlabs.com/RPM-GPG-KEY-reductive',
		],
		ensure => present,
	}

	yum::repos::repo { 'puppetlabs-other':
		baseurl => "https://yum.puppetlabs.com/el/${version}/dependencies/x86_64/",
		enabled => true,
		gpgcheck => true,
		gpgkeys => [	# XXX: these should be files, not https:// links
			'https://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs',
			'https://yum.puppetlabs.com/RPM-GPG-KEY-reductive',
		],
		ensure => present,
	}
}

# vim: ts=8
