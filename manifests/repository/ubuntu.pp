# == Class: midonet::repository::ubuntu
# NOTE: don't use this class, use midonet::repository(::init) instead
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

class midonet::repository::ubuntu (
    $midonet_repo,
    $midonet_stage,
    $midonet_openstack_repo,
    $midonet_thirdparty_repo,
    $midonet_key,
    $midonet_key_url,
    $openstack_release)
    {
        # Adding repository for ubuntu
        notice('Adding midonet sources for Debian-like distribution')
        if $::lsbdistrelease == '14.04' or $::lsbdistrelease == '12.04' {
            if $::lsbdistrelease == '12.04' and $openstack_release == 'juno' {
                fail ('Ubuntu 12.04 only supports icehouse')
            }
            notice('Adding midonet sources for Debian-like distribution')

            include apt
            include apt::update

            # Update the package list each time a package is defined. That takes
            # time, but it ensures it will not fail for out of date repository info
            # Exec['apt_update'] -> Package<| |>

            apt::source {'midonet':
                comment     => 'Midonet apt repository',
                location    => $midonet_repo,
                release     => $midonet_stage,
                key         => $midonet_key,
                key_source  => $midonet_key_url,
                include_src => false,
            }

            apt::source {'midonet-openstack-integration':
                comment     => 'Midonet apt plugin repository',
                location    => $midonet_openstack_repo,
                release     => $midonet_stage,
                include_src => false,
            }

            # Dummy exec to wrap apt_update
            exec {'update-midonet-repos':
                command => '/bin/true',
                require => [Exec['apt_update'],
                            Apt::Source['midonet'],
                            Apt::Source['midonet-openstack-integration']]

            }

            Apt::Source<| |> -> Exec<| command == 'update-midonet-repos' |>

        }
        else
        {
            fail("${::lsbdistid} ${::lsbdistrelease} version not supported")
        }
    }
