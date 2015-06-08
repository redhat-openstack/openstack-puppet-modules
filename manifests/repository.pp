# == Class: midonet::repository
#
# Prepare the midonet repositories to install packages.
#
# === Parameters
#
# [*midonet_repo*]
#   Midonet Repository URL location. Please note the version
#   of midonet use to be part of that URL.
#   Ex: 'http://repo.midonet.org/midonet/v2014.11'
# [*midonet_openstack_repo*]
#   Midonet Repository URL for the Midonet Neutron Plugin. The version use to
#   be part of the URL. The package avaiable in this repo (the midonet plugin)
#   is released along each OpenStack release (Icehouse, Juno, Kilo...) , not
#   the Midonet OSS release. This is why Midonet maintains different repos.
#   Ex: 'http://repo.midonet.org/openstack'.
# [*midonet_thirdparty_repo*]
#   Third party software pinned for Midonet stability URL.
#   Ex: 'http://repo.midonet.org/misc'.
# [*midonet_release*]
#   Stage of the package. It can be 'stable', 'testing' or 'unstable'.
#   Stable by default.
# [*midoney_key_url*]
#   Midonet Key URL path.
# [*midonet_key*]
#   Midonet GPG key for validate packages. Only override it if you use a
#   different fork of Midonet.
#
# === Examples
#
# The easiest way to run the class is:
#
#      include midonet::repository
#
# And puppet will configure the system to use the latest stable version
# of MidoNet OSS.
#
# To install other releases than the last default's Midonet OSS, you can
# override the default's midonet_repository atributes by a resource-like
# declaration:
#
#     class { 'midonet::repository':
#         midonet_repo            => 'http://repo.midonet.org/midonet/v2014.11',
#         midonet_openstack_repo  => 'http://repo.midonet.org/openstack',
#         midonet_thirdparty_repo => 'http://repo.midonet.org/misc',
#         midonet_key             => '50F18FCF',
#         midonet_stage           => 'stable',
#         midonet_key_url         => 'http://repo.midonet.org/packages.midokura.key',
#         openstack_release       => 'juno'
#     }
#
# or use a YAML file using the same attributes, accessible from Hiera:
#
#     midonet::repository::midonet_repo: 'http://repo.midonet.org/midonet/v2014.11'
#     midonet::repository::midonet_openstack_repo: 'http://repo.midonet.org/openstack'
#     midonet::repository::midonet_thirdparty_repo: 'http://repo.midonet.org/misc'
#     midonet::repository::midonet_key: '50F18FCF'
#     midonet::repository::midonet_stage: 'stable'
#     midonet::repository::midonet_key_url: 'http://repo.midonet.org/packages.midokura.key'
#     midonet::repository::openstack_release: 'juno'
#
#
# === Authors
#
# Midonet (http://midonet.org)
#
# === Copyright
#
# Copyright (c) 2015 Midokura SARL, All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class midonet::repository (
    $midonet_repo,
    $midonet_openstack_repo,
    $midonet_thirdparty_repo,
    $midonet_stage,
    $openstack_release,
    $midonet_key_url,
    $midonet_key=unset) {

    case $::osfamily {
        'Debian': {
            class {'midonet::repository::ubuntu':
                midonet_repo            => $midonet_repo,
                midonet_openstack_repo  => $midonet_openstack_repo,
                midonet_thirdparty_repo => $midonet_thirdparty_repo,
                midonet_stage           => $midonet_stage,
                openstack_release       => $openstack_release,
                midonet_key_url         => $midonet_key_url,
                midonet_key             => $midonet_key
            }
        }

        'RedHat': {
            class {'midonet::repository::centos':
                midonet_repo            => $midonet_repo,
                midonet_openstack_repo  => $midonet_openstack_repo,
                midonet_thirdparty_repo => $midonet_thirdparty_repo,
                midonet_stage           => $midonet_stage,
                openstack_release       => $openstack_release,
                midonet_key_url         => $midonet_key_url
            }
        }

        default: {
            fail('Operating System not supported by this module')
        }
    }
}
