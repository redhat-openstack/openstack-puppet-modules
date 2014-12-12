#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: cloud::storage::rbd::pools
#
# Configure Ceph RBD pools (images,volumes,backup,nova)
#
# === Parameters:
#
# [*setup_pools*]
#   (optional) Create or not Ceph pools
#   Defaults to false
#
# [*glance_rbd_pool*]
#   (optional) Name of the Ceph pool which which store the glance images
#   Defaults to 'images'
#
# [*glance_rbd_user*]
#   (optional) User name used to acces to the glance rbd pool
#   Defaults to 'glance'
#
# [*ceph_fsid*] The cluster's fsid.
#   Mandatory. Get one with `uuidgen -r`.
#
# [*cinder_backup_pool*]
#   (optional) Name of the Ceph pool which which store the cinder backups
#   Defaults to 'volumes'
#
# [*cinder_backup_user*]
#   (optional) User name used to acces to the backup rbd pool
#   Defaults to 'cinder'
#
# [*cinder_rbd_pool*]
#   (optional) Name of the Ceph pool which which store the cinder images
#   Defaults to 'volumes'
#
# [*cinder_rbd_user*]
#   (optional) User name used to acces to the cinder rbd pool
#   Defaults to 'cinder'
#
# [*nova_rbd_pool*]
#   (optional) The RADOS pool in which rbd volumes are stored.
#   Defaults to 'vms'
#
class cloud::storage::rbd::pools(
  $setup_pools          = false,
  $glance_rbd_user      = 'glance',
  $glance_rbd_pool      = 'images',
  $cinder_rbd_user      = 'cinder',
  $cinder_rbd_pool      = 'volumes',
  $nova_rbd_pool        = 'vms',
  $cinder_backup_user   = 'cinder',
  $cinder_backup_pool   = 'cinder_backup',
  $ceph_fsid            = undef
) {

  if $setup_pools {
    if !empty($::ceph_admin_key) {

      exec { "create_${glance_rbd_pool}_pool":
        command => "rados mkpool ${glance_rbd_pool}",
        unless  => "rados lspools | grep -sq ${glance_rbd_pool}",
      }

      exec { "create_${glance_rbd_pool}_user_and_key":
        command => "ceph auth get-or-create client.${glance_rbd_user} mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=${glance_rbd_pool}'",
        unless  => "ceph auth list 2> /dev/null | egrep -sq '^client.${glance_rbd_user}$'",
        require => Exec["create_${glance_rbd_pool}_pool"];
      }

      exec { "create_${cinder_rbd_pool}_pool":
        command => "rados mkpool ${cinder_rbd_pool}",
        unless  => "/usr/bin/rados lspools | grep -sq ${cinder_rbd_pool}",
      }

      exec { "create_${cinder_rbd_pool}_user_and_key":
        # TODO: point PG num with a cluster variable
        command => "ceph auth get-or-create client.${cinder_rbd_user} mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rx pool=${glance_rbd_pool}, allow rwx pool=${cinder_rbd_pool}, allow rwx pool=${nova_rbd_pool}'",
        unless  => "ceph auth list 2> /dev/null | egrep -sq '^client.${cinder_rbd_user}$'",
        require => Exec["create_${cinder_rbd_pool}_pool"];
      }

      # Note(EmilienM): We use the same keyring for Nova and Cinder.
      exec { "create_${nova_rbd_pool}_pool":
        command => "rados mkpool ${nova_rbd_pool}",
        unless  => "/usr/bin/rados lspools | grep -sq ${nova_rbd_pool}",
      }

      if $::ceph_keyring_glance {
        # NOTE(fc): Puppet needs to run a second time to enter this
        @@ceph::key { $glance_rbd_user:
          secret       => $::ceph_keyring_glance,
          keyring_path => "/etc/ceph/ceph.client.${glance_rbd_user}.keyring"
        }
        Ceph::Key <<| title == $glance_rbd_user |>>
      }

      if $::ceph_keyring_cinder {
        # NOTE(fc): Puppet needs to run a second time to enter this
        @@ceph::key { $cinder_rbd_user:
          secret       => $::ceph_keyring_cinder,
          keyring_path => "/etc/ceph/ceph.client.${cinder_rbd_user}.keyring"
        }
        Ceph::Key <<| title == $cinder_rbd_user |>>
      }

      $clients = [$glance_rbd_user, $cinder_rbd_user]
      @@concat::fragment { 'ceph-clients-os':
        target  => '/etc/ceph/ceph.conf',
        order   => '95',
        content => template('cloud/storage/ceph/ceph-client.conf.erb')
      }

      @@file { '/etc/ceph/secret.xml':
        content => template('cloud/storage/ceph/secret-compute.xml.erb'),
        tag     => 'ceph_compute_secret_file',
      }

      if $::osfamily == 'RedHat' {
        $libvirt_package_name = 'libvirt'
      } else {
        $libvirt_package_name = 'libvirt-bin'
      }

      @@exec { 'get_or_set_virsh_secret':
        command => 'virsh secret-define --file /etc/ceph/secret.xml',
        unless  => "virsh secret-list | tail -n +3 | cut -f1 -d' ' | grep -sq ${ceph_fsid}",
        tag     => 'ceph_compute_get_secret',
        require => [Package[$libvirt_package_name],File['/etc/ceph/secret.xml']],
        notify  => Exec['set_secret_value_virsh'],
      }

      @@exec { 'set_secret_value_virsh':
        command     => "virsh secret-set-value --secret ${ceph_fsid} --base64 ${::ceph_keyring_cinder}",
        tag         => 'ceph_compute_set_secret',
        refreshonly =>  true,
      }

    } # !empty($::ceph_admin_key)
  } # if setup pools
} # class
