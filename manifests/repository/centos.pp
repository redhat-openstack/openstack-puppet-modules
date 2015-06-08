# == Class: midonet::repository::centos
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

class midonet::repository::centos (
    $midonet_repo,
    $midonet_openstack_repo,
    $midonet_thirdparty_repo,
    $midonet_stage,
    $openstack_release,
    $midonet_key_url)
    {
        # Adding repository for ubuntu
        notice('Adding midonet sources for RedHat-like distribution')
        if ($::operatingsystemmajrelease == 6 or
            $::operatingsystemmajrelease == 7) {
            if ($::operatingsystemmajrelease == 6 and
                $openstack_release == 'juno') {
                fail ("CentOS/Redhat 6 only supports
                      'openstack_release => icehouse'")
            }

            yumrepo { 'midonet':
                baseurl  => "${midonet_repo}/${::operatingsystemmajrelease}/${midonet_stage}",
                descr    => 'Midonet base repo',
                enabled  => 1,
                gpgcheck => 1,
                gpgkey   => $midonet_key_url,
                timeout  => 60
            }

            yumrepo { 'midonet-openstack-integration':
                baseurl  => "${midonet_openstack_repo}/${::operatingsystemmajrelease}/${midonet_stage}",
                descr    => 'Midonet OS plugin repo',
                enabled  => 1,
                gpgcheck => 1,
                gpgkey   => $midonet_key_url,
                timeout  => 60
            }

            package { 'epel-release':
                ensure   => installed
            }

            package { 'rdo-release':
                ensure   => installed,
                source   => "https://repos.fedorapeople.org/repos/openstack/openstack-${openstack_release}/rdo-release-${openstack_release}.rpm",
                provider => 'rpm',
                require  => Package['epel-release']
            }

            exec {'update-midonet-repos':
              command => '/usr/bin/yum clean all && /usr/bin/yum makecache'
            }

            Yumrepo<| |> -> Exec<| command == 'update-midonet-repos' |>
            Package<| |> -> Exec<| command == 'update-midonet-repos' |>
        }
        else
        {
            fail("RedHat/CentOS version ${::operatingsystemmajrelease}
                  not supported")
        }
    }
