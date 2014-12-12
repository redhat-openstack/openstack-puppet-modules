#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
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
# == Class: cloud::compute::hypervisor
#
# Hypervisor Compute node
#
# === Parameters:
#
# [*server_proxyclient_address*]
#   (optional) Hostname or IP used to connect to Spice service.
#   Defaults to '127.0.0.1'
#
# [*libvirt_type*]
#   (optional) Libvirt domain type. Options are: kvm, lxc, qemu, uml, xen
#   Replaces libvirt_type
#   Defaults to 'kvm'
#
# [*ks_nova_public_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_nova_public_host*]
#   (optional) Public Hostname or IP to connect to Nova API
#   Defaults to '127.0.0.1'
#
# [*nova_ssh_public_key*]
#   (optional) Install public key in .ssh/authorized_keys for the 'nova' user.
#   Note: this parameter use the 'content' provider of Puppet, in consequence
#   you must provide the entire ssh public key in this parameter.
#   Defaults to undef
#
# [*nova_ssh_private_key*]
#   (optional) Install private key into .ssh/id_rsa.
#   Note: this parameter use the 'content' provider of Puppet, in consequence
#   you must provide the entire ssh privatekey in this parameter.
#   Defaults to undef
#
# [*spice_port*]
#   (optional) TCP port to connect to Nova spicehtmlproxy service.
#   Defaults to '6082'
#
# [*cinder_rbd_user*]
#   (optional) The RADOS client name for accessing rbd volumes.
#   Defaults to 'cinder'
#
# [*nova_rbd_pool*]
#   (optional) The RADOS pool in which rbd volumes are stored.
#   Defaults to 'vms'
#
# [*nova_rbd_secret_uuid*]
#   (optional) The libvirt uuid of the secret for the cinder_rbd_user.
#   Defaults to undef
#
# [*vm_rbd*]
#   (optional) Enable or not ceph capabilities on compute node to store
#   nova instances on ceph storage.
#   Default to false.
#
# [*volume_rbd*]
#   (optional) Enable or not ceph capabilities on compute node to attach
#   cinder volumes backend by ceph on nova instances.
#   Default to false.
#
# [*manage_tso*]
#   (optional) Allow to manage or not TSO issue.
#   Default to true.
#
# [*nfs_enabled*]
#   (optional) Store (or not) instances on a NFS share.
#   Defaults to false
#
# [*nfs_device*]
#   (optional) NFS device to mount
#   Example: 'nfs.example.com:/vol1'
#   Required when nfs_enabled is at true.
#   Defaults to false
#
# [*nfs_options*]
#   (optional) NFS mount options
#   Example: 'nfsvers=3,noacl'
#   Defaults to 'defaults'
#
# [*filesystem_store_datadir*]
#   (optional) Full path of data directory to store the instances.
#   Don't modify this parameter if you don't know what you do.
#   You may have side effects (SElinux for example).
#   Defaults to '/var/lib/nova/instances'
#
# [*nova_shell*]
#   (optional) Full path of shell to run for nova user.
#   To disable live migration & resize, set it to '/bin/nologin' or false.
#   Otherwise, set the value to '/bin/bash'.
#   Need to be a valid shell path.
#   Defaults to false
#
# [*ks_spice_public_proto*]
#   (optional) Protocol used to connect to Spice service.
#   Defaults to false (use nova_public_proto)
#
# [*ks_spice_public_host*]
#   (optional) Hostname or IP used to connect to Spice service.
#   Defaults to false (use nova_public_host)
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::compute::hypervisor(
  $server_proxyclient_address = '127.0.0.1',
  $libvirt_type               = 'kvm',
  $ks_nova_public_proto       = 'http',
  $ks_nova_public_host        = '127.0.0.1',
  $nova_ssh_private_key       = undef,
  $nova_ssh_public_key        = undef,
  $spice_port                 = 6082,
  $cinder_rbd_user            = 'cinder',
  $nova_rbd_pool              = 'vms',
  $nova_rbd_secret_uuid       = undef,
  $vm_rbd                     = false,
  $volume_rbd                 = false,
  $manage_tso                 = true,
  $nova_shell                 = false,
  $firewall_settings          = {},
  # when using NFS storage backend
  $nfs_enabled                = false,
  $nfs_device                 = false,
  $nfs_options                = 'defaults',
  $filesystem_store_datadir   = '/var/lib/nova/instances',
  $ks_spice_public_proto      = 'http',
  $ks_spice_public_host       = '127.0.0.1',
) inherits cloud::params {

  include 'cloud::compute'
  include 'cloud::params'
  include 'cloud::telemetry'
  include 'cloud::network'
  include 'cloud::network::vswitch'

  if $libvirt_type == 'kvm' and ! $::vtx {
    fail('libvirt_type is set to KVM and VTX seems to be disabled on this node.')
  }

  if $nfs_enabled {
    if ! $vm_rbd {
      # There is no NFS backend in Nova.
      # We mount the NFS share in filesystem_store_datadir to fake the
      # backend.
      if $nfs_device {
        nova_config { 'DEFAULT/instances_path': value => $filesystem_store_datadir; }
        $nfs_mount = {
          "${filesystem_store_datadir}" => {
            'ensure'  => 'mounted',
            'fstype'  => 'nfs',
            'device'  => $nfs_device,
            'options' => $nfs_options
          }
        }
        ensure_resource('class', 'nfs', {})
        create_resources('types::mount', $nfs_mount)

        # Not using /var/lib/nova/instances may cause side effects.
        if $filesystem_store_datadir != '/var/lib/nova/instances' {
          warning('filesystem_store_datadir is not /var/lib/nova/instances so you may have side effects (SElinux, etc)')
        }
      } else {
        fail('When running NFS backend, you need to provide nfs_device parameter.')
      }
    } else {
      fail('When running NFS backend, vm_rbd parameter cannot be set to true.')
    }
  }

  file{ '/var/lib/nova/.ssh':
    ensure  => directory,
    mode    => '0700',
    owner   => 'nova',
    group   => 'nova',
    require => Class['nova']
  } ->
  file{ '/var/lib/nova/.ssh/id_rsa':
    ensure  => present,
    mode    => '0600',
    owner   => 'nova',
    group   => 'nova',
    content => $nova_ssh_private_key
  } ->
  file{ '/var/lib/nova/.ssh/authorized_keys':
    ensure  => present,
    mode    => '0600',
    owner   => 'nova',
    group   => 'nova',
    content => $nova_ssh_public_key
  } ->
  file{ '/var/lib/nova/.ssh/config':
    ensure  => present,
    mode    => '0600',
    owner   => 'nova',
    group   => 'nova',
    content => "
Host *
    StrictHostKeyChecking no
"
  }

  if $nova_shell {
    ensure_resource ('user', 'nova', {
      'ensure'     => 'present',
      'system'     => true,
      'home'       => '/var/lib/nova',
      'managehome' => false,
      'shell'      => $nova_shell,
    })
  }

  class { 'nova::compute':
    enabled         => true,
    vnc_enabled     => false,
    #TODO(EmilienM) Bug #1259545 currently WIP:
    virtio_nic      => false,
    neutron_enabled => true
  }

  class { 'nova::compute::spice':
    server_listen              => '0.0.0.0',
    server_proxyclient_address => $server_proxyclient_address,
    proxy_host                 => $ks_spice_public_host,
    proxy_protocol             => $ks_spice_public_proto,
    proxy_port                 => $spice_port

  }

  if $::osfamily == 'RedHat' {
    file { '/etc/libvirt/qemu.conf':
      ensure => file,
      source => 'puppet:///modules/cloud/qemu/qemu.conf',
      owner  => root,
      group  => root,
      mode   => '0644',
      notify => Service['libvirtd']
    }
    if $vm_rbd and ($::operatingsystemmajrelease < 7) {
      fail("RBD image backend in Nova is not supported in RHEL ${::operatingsystemmajrelease}.")
    }
  }

  # Disabling TSO/GSO/GRO
  if $manage_tso {
    if $::osfamily == 'Debian' {
      ensure_resource ('exec','enable-tso-script', {
        'command' => '/usr/sbin/update-rc.d disable-tso defaults',
        'unless'  => '/bin/ls /etc/rc*.d | /bin/grep disable-tso',
        'onlyif'  => '/usr/bin/test -f /etc/init.d/disable-tso'
      })
    } elsif $::osfamily == 'RedHat' {
      ensure_resource ('exec','enable-tso-script', {
        'command' => '/usr/sbin/chkconfig disable-tso on',
        'unless'  => '/bin/ls /etc/rc*.d | /bin/grep disable-tso',
        'onlyif'  => '/usr/bin/test -f /etc/init.d/disable-tso'
      })
    }
    ensure_resource ('exec','start-tso-script', {
      'command' => '/etc/init.d/disable-tso start',
      'unless'  => '/usr/bin/test -f /var/run/disable-tso.pid',
      'onlyif'  => '/usr/bin/test -f /etc/init.d/disable-tso'
    })
  }

  if $::operatingsystem == 'Ubuntu' {
    service { 'dbus':
      ensure => running,
      enable => true,
      before => Class['nova::compute::libvirt'],
    }
  }

  Service<| title == 'dbus' |> { enable => true }

  Service<| title == 'libvirt-bin' |> { enable => true }

  class { 'nova::compute::neutron': }

  if $vm_rbd or $volume_rbd {

    include 'cloud::storage::rbd'

    $libvirt_disk_cachemodes_real = ['network=writeback']

    # when nova uses ceph for instances storage
    if $vm_rbd {
      class { 'nova::compute::rbd':
        libvirt_rbd_user        => $cinder_rbd_user,
        libvirt_images_rbd_pool => $nova_rbd_pool
      }
    } else {
      # when nova only needs to attach ceph volumes to instances
      nova_config {
        'libvirt/rbd_user': value => $cinder_rbd_user;
      }
    }
    # we don't want puppet-nova manages keyring
    nova_config {
      'libvirt/rbd_secret_uuid': value => $nova_rbd_secret_uuid;
    }

    File <<| tag == 'ceph_compute_secret_file' |>>
    Exec <<| tag == 'get_or_set_virsh_secret' |>>

    # After setting virsh key, we need to restart nova-compute
    # otherwise nova will fail to connect to RADOS.
    Exec <<| tag == 'set_secret_value_virsh' |>> ~> Service['nova-compute']

    # If Cinder & Nova reside on the same node, we need a group
    # where nova & cinder users have read permissions.
    ensure_resource('group', 'cephkeyring', {
      ensure => 'present'
    })

    ensure_resource ('exec','add-nova-to-group', {
      'command' => 'usermod -a -G cephkeyring nova',
      'path'    => ['/usr/sbin', '/usr/bin', '/bin', '/sbin'],
      'unless'  => 'groups nova | grep cephkeyring'
    })

    # Configure Ceph keyring
    Ceph::Key <<| title == $cinder_rbd_user |>>
    if defined(Ceph::Key[$cinder_rbd_user]) {
      ensure_resource(
        'file',
        "/etc/ceph/ceph.client.${cinder_rbd_user}.keyring", {
          owner   => 'root',
          group   => 'cephkeyring',
          mode    => '0440',
          require => Ceph::Key[$cinder_rbd_user],
          notify  => Service['nova-compute'],
        }
      )
    }

    Concat::Fragment <<| title == 'ceph-client-os' |>>
  } else {
    $libvirt_disk_cachemodes_real = []
  }

  class { 'nova::compute::libvirt':
    libvirt_type            => $libvirt_type,
    # Needed to support migration but we still use Spice:
    vncserver_listen        => '0.0.0.0',
    migration_support       => true,
    libvirt_disk_cachemodes => $libvirt_disk_cachemodes_real,
    libvirt_service_name    => $::cloud::params::libvirt_service_name,
  }

  # Extra config for nova-compute
  nova_config {
    'libvirt/inject_key':            value => false;
    'libvirt/inject_partition':      value => '-2';
    'libvirt/live_migration_flag':   value => 'VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_PERSIST_DEST';
    'libvirt/block_migration_flag':  value => 'VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_NON_SHARED_INC';
  }

  class { 'ceilometer::agent::compute': }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow instances console access':
      port   => '5900-5999',
      extras => $firewall_settings,
    }
    cloud::firewall::rule{ '100 allow instances migration access':
      port   => ['16509', '49152-49215'],
      extras => $firewall_settings,
    }
  }

}
