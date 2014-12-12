#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless optional by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# MySQL Galera Node
#
# === Parameters
#
# [*api_eth*]
#   (optional) Hostname or IP to bind MySQL daemon.
#   Defaults to '127.0.0.1'
#
# [*galera_master_name*]
#   (optional) Hostname or IP of the Galera master node, databases and users
#   resources are created on this node and propagated on the cluster.
#   Defaults to 'mgmt001'
#
# [*galera_internal_ips*]
#   (optional) Array of internal ip of the galera nodes.
#   Defaults to ['127.0.0.1']
#
# [*galera_gcache*]
#   (optional) Size of the Galera gcache
#   wsrep_provider_options, for master/slave mode
#   Defaults to '1G'
#
# [*keystone_db_host*]
#   (optional) Host where user should be allowed all privileges for database.
#   Defaults to 127.0.0.1
#
# [*keystone_db_user*]
#   (optional) Name of keystone DB user.
#   Defaults to trove
#
# [*keystone_db_password*]
#   (optional) Password that will be used for the Keystone db user.
#   Defaults to 'keystonepassword'
#
# [*keystone_db_allowed_hosts*]
#   (optional) Hosts allowed to use the database
#   Defaults to ['127.0.0.1']
#
# [*cinder_db_host*]
#   (optional) Host where user should be allowed all privileges for database.
#   Defaults to 127.0.0.1
#
# [*cinder_db_user*]
#   (optional) Name of cinder DB user.
#   Defaults to trove
#
# [*cinder_db_password*]
#   (optional) Password that will be used for the cinder db user.
#   Defaults to 'cinderpassword'
#
# [*cinder_db_allowed_hosts*]
#   (optional) Hosts allowed to use the database
#   Defaults to ['127.0.0.1']
#
# [*glance_db_host*]
#   (optional) Host where user should be allowed all privileges for database.
#   Defaults to 127.0.0.1
#
# [*glance_db_user*]
#   (optional) Name of glance DB user.
#   Defaults to trove
#
# [*glance_db_password*]
#   (optional) Password that will be used for the glance db user.
#   Defaults to 'glancepassword'
#
# [*glance_db_allowed_hosts*]
#   (optional) Hosts allowed to use the database
#   Defaults to ['127.0.0.1']
#
# [*heat_db_host*]
#   (optional) Host where user should be allowed all privileges for database.
#   Defaults to 127.0.0.1
#
# [*heat_db_user*]
#   (optional) Name of heat DB user.
#   Defaults to trove
#
# [*heat_db_password*]
#   (optional) Password that will be used for the heat db user.
#   Defaults to 'heatpassword'
#
# [*heat_db_allowed_hosts*]
#   (optional) Hosts allowed to use the database
#   Defaults to ['127.0.0.1']
#
# [*nova_db_host*]
#   (optional) Host where user should be allowed all privileges for database.
#   Defaults to 127.0.0.1
#
# [*nova_db_user*]
#   (optional) Name of nova DB user.
#   Defaults to trove
#
# [*nova_db_password*]
#   (optional) Password that will be used for the nova db user.
#   Defaults to 'novapassword'
#
# [*nova_db_allowed_hosts*]
#   (optional) Hosts allowed to use the database
#   Defaults to ['127.0.0.1']
#
# [*neutron_db_host*]
#   (optional) Host where user should be allowed all privileges for database.
#   Defaults to 127.0.0.1
#
# [*neutron_db_user*]
#   (optional) Name of neutron DB user.
#   Defaults to trove
#
# [*neutron_db_password*]
#   (optional) Password that will be used for the neutron db user.
#   Defaults to 'neutronpassword'
#
# [*neutron_db_allowed_hosts*]
#   (optional) Hosts allowed to use the database
#   Defaults to ['127.0.0.1']
#
# [*trove_db_host*]
#   (optional) Host where user should be allowed all privileges for database.
#   Defaults to 127.0.0.1
#
# [*trove_db_user*]
#   (optional) Name of trove DB user.
#   Defaults to trove
#
# [*trove_db_password*]
#   (optional) Password that will be used for the trove db user.
#   Defaults to 'trovepassword'
#
# [*trove_db_allowed_hosts*]
#   (optional) Hosts allowed to use the database
#   Defaults to ['127.0.0.1']
#
# [*mysql_root_password*]
#   (optional) The MySQL root password.
#   Puppet will attempt to set the root password and update `/root/.my.cnf` with it.
#   Defaults to 'rootpassword'
#
# [*mysql_sys_maint_password*]
#   (optional) The MySQL debian-sys-maint password.
#   Debian only parameter.
#   Defaults to 'sys_maint'
#
# [*galera_clustercheck_dbuser*]
#   (optional) The MySQL username for Galera cluster check (using monitoring database)
#   Defaults to 'clustercheckdbuser'
#
# [*galera_clustercheck_dbpassword*]
#   (optional) The MySQL password for Galera cluster check
#   Defaults to 'clustercheckpassword'
#
# [*galera_clustercheck_ipaddress*]
#   (optional) The name or ip address of host running monitoring database (clustercheck)
#   Defaults to '127.0.0.1'
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
# ==== Deprecated parameters:
#
# [*service_provider*]
#   Previously used to choose between sysv and systemd, yes suppressed
#   because this subject is potentially a troll :-D
#   Defaults to 'sysv'
#
class cloud::database::sql (
    $api_eth                        = '127.0.0.1',
    $galera_master_name             = 'mgmt001',
    $galera_internal_ips            = ['127.0.0.1'],
    $galera_gcache                  = '1G',
    $keystone_db_host               = '127.0.0.1',
    $keystone_db_user               = 'keystone',
    $keystone_db_password           = 'keystonepassword',
    $keystone_db_allowed_hosts      = ['127.0.0.1'],
    $cinder_db_host                 = '127.0.0.1',
    $cinder_db_user                 = 'cinder',
    $cinder_db_password             = 'cinderpassword',
    $cinder_db_allowed_hosts        = ['127.0.0.1'],
    $glance_db_host                 = '127.0.0.1',
    $glance_db_user                 = 'glance',
    $glance_db_password             = 'glancepassword',
    $glance_db_allowed_hosts        = ['127.0.0.1'],
    $heat_db_host                   = '127.0.0.1',
    $heat_db_user                   = 'heat',
    $heat_db_password               = 'heatpassword',
    $heat_db_allowed_hosts          = ['127.0.0.1'],
    $nova_db_host                   = '127.0.0.1',
    $nova_db_user                   = 'nova',
    $nova_db_password               = 'novapassword',
    $nova_db_allowed_hosts          = ['127.0.0.1'],
    $neutron_db_host                = '127.0.0.1',
    $neutron_db_user                = 'neutron',
    $neutron_db_password            = 'neutronpassword',
    $neutron_db_allowed_hosts       = ['127.0.0.1'],
    $trove_db_host                  = '127.0.0.1',
    $trove_db_user                  = 'trove',
    $trove_db_password              = 'trovepassword',
    $trove_db_allowed_hosts         = ['127.0.0.1'],
    $mysql_root_password            = 'rootpassword',
    $mysql_sys_maint_password       = 'sys_maint',
    $galera_clustercheck_dbuser     = 'clustercheckdbuser',
    $galera_clustercheck_dbpassword = 'clustercheckpassword',
    $galera_clustercheck_ipaddress  = '127.0.0.1',
    $firewall_settings              = {},
    # DEPRECATED PARAMETERS
    $service_provider               = 'sysv',
) {

  include 'xinetd'

  $gcomm_definition = inline_template('<%= @galera_internal_ips.join(",") + "?pc.wait_prim=no" -%>')

  # Specific to the Galera master node
  if $::hostname == $galera_master_name {

    $mysql_root_password_real = $mysql_root_password

    # OpenStack DB
    class { 'keystone::db::mysql':
      mysql_module  => '2.2',
      dbname        => 'keystone',
      user          => $keystone_db_user,
      password      => $keystone_db_password,
      host          => $keystone_db_host,
      allowed_hosts => $keystone_db_allowed_hosts,
    }
    class { 'glance::db::mysql':
      mysql_module  => '2.2',
      dbname        => 'glance',
      user          => $glance_db_user,
      password      => $glance_db_password,
      host          => $glance_db_host,
      allowed_hosts => $glance_db_allowed_hosts,
    }
    class { 'nova::db::mysql':
      mysql_module  => '2.2',
      dbname        => 'nova',
      user          => $nova_db_user,
      password      => $nova_db_password,
      host          => $nova_db_host,
      allowed_hosts => $nova_db_allowed_hosts,
    }
    class { 'cinder::db::mysql':
      mysql_module  => '2.2',
      dbname        => 'cinder',
      user          => $cinder_db_user,
      password      => $cinder_db_password,
      host          => $cinder_db_host,
      allowed_hosts => $cinder_db_allowed_hosts,
    }
    class { 'neutron::db::mysql':
      mysql_module  => '2.2',
      dbname        => 'neutron',
      user          => $neutron_db_user,
      password      => $neutron_db_password,
      host          => $neutron_db_host,
      allowed_hosts => $neutron_db_allowed_hosts,
    }
    class { 'heat::db::mysql':
      mysql_module  => '2.2',
      dbname        => 'heat',
      user          => $heat_db_user,
      password      => $heat_db_password,
      host          => $heat_db_host,
      allowed_hosts => $heat_db_allowed_hosts,
    }
    class { 'trove::db::mysql':
      mysql_module  => '2.2',
      dbname        => 'trove',
      user          => $trove_db_user,
      password      => $trove_db_password,
      host          => $trove_db_host,
      allowed_hosts => $trove_db_allowed_hosts,
    }

    # Monitoring DB
    mysql_database { 'monitoring':
      ensure  => 'present',
      charset => 'utf8',
      collate => 'utf8_unicode_ci',
      require => File['/root/.my.cnf']
    }
    mysql_user { "${galera_clustercheck_dbuser}@localhost":
      ensure        => 'present',
      # can not change password in clustercheck script
      password_hash => mysql_password($galera_clustercheck_dbpassword),
      require       => File['/root/.my.cnf']
    }
    mysql_grant { "${galera_clustercheck_dbuser}@localhost/monitoring":
      ensure     => 'present',
      options    => ['GRANT'],
      privileges => ['ALL'],
      table      => 'monitoring.*',
      user       => "${galera_clustercheck_dbuser}@localhost",
    }

    Database_user<<| |>>
  } else {
    # NOTE(sileht): Only the master must create the password
    # into the database, slave nodes must just use the password.
    # The one in the database have been retrieved via galera.
    file { "${::root_home}/.my.cnf":
      content => "[client]\nuser=root\nhost=localhost\npassword=${mysql_root_password}\n",
      owner   => 'root',
      mode    => '0600',
    }
  }

  # Specific to Red Hat or Debian systems:
  case $::osfamily {
    'RedHat': {
      # Specific to Red Hat
      $mysql_server_package_name = 'mariadb-galera-server'
      $mysql_client_package_name = 'mariadb'
      $wsrep_provider = '/usr/lib64/galera/libgalera_smm.so'
      $mysql_server_config_file = '/etc/my.cnf'
      $mysql_init_file = '/usr/lib/systemd/system/mysql-bootstrap.service'

      if $::hostname == $galera_master_name {
        $mysql_service_name = 'mysql-bootstrap'
      } else {
        $mysql_service_name = 'mariadb'
      }

      $dirs = [ '/var/run/mysqld', '/var/log/mysql' ]

      file { $dirs:
        ensure => directory,
        mode   => '0750',
        before => Service['mysqld'],
        owner  => 'mysql'
      }

      # In Red Hat, the package does not perform the mysql db installation.
      # We need to do this manually.
      # Note: in MariaDB repository, package perform this action in post-install,
      # but MariaDB is not packaged for Red Hat / CentOS 7 in MariaDB repository.
      exec { 'bootstrap-mysql':
        command => '/usr/bin/mysql_install_db --rpm --user=mysql',
        unless  => 'test -d /var/lib/mysql/mysql',
        before  => Service['mysqld'],
        require => [Package[$mysql_server_package_name], File[$mysql_server_config_file]]
      }

    } # RedHat
    'Debian': {
      # Specific to Debian / Ubuntu
      $mysql_server_package_name = 'mariadb-galera-server'
      $mysql_client_package_name = 'mariadb-client'
      $wsrep_provider = '/usr/lib/galera/libgalera_smm.so'
      $mysql_server_config_file = '/etc/mysql/my.cnf'
      $mysql_init_file = '/etc/init.d/mysql-bootstrap'

      if $::hostname == $galera_master_name {
        $mysql_service_name = 'mysql-bootstrap'
      } else {
        $mysql_service_name = 'mysql'
      }

      mysql_user { 'debian-sys-maint@localhost':
        ensure        => 'present',
        password_hash => mysql_password($mysql_sys_maint_password),
        require       => File['/root/.my.cnf']
      }

      file{'/etc/mysql/debian.cnf':
        ensure  => file,
        content => template('cloud/database/debian.cnf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        require => Exec['clean-mysql-binlog'],
      }
    } # Debian
    default: {
      err "${::osfamily} not supported yet"
    }
  }

  # This is due to this bug: https://bugs.launchpad.net/codership-mysql/+bug/1087368
  # The backport to API 23 requires a command line option --wsrep-new-cluster:
  # http://bazaar.launchpad.net/~codership/codership-mysql/wsrep-5.5/revision/3844?start_revid=3844
  # and the mysql init script cannot have arguments passed to the daemon
  # using /etc/default/mysql standart mechanism.
  # To check that the mysqld support the options you can :
  # strings `which mysqld` | grep wsrep-new-cluster
  # TODO: to be remove as soon as the API 25 is packaged, ie galera 3 ...
  file { $mysql_init_file :
    content => template("cloud/database/etc_initd_mysql_${::osfamily}"),
    owner   => 'root',
    mode    => '0755',
    group   => 'root',
    notify  => Service['mysqld'],
    before  => Package[$mysql_server_package_name],
  }

  if($::osfamily == 'Debian'){
    # The startup time can be longer than the default 30s so we take
    # care of it there.  Until this bug is not resolved
    # https://mariadb.atlassian.net/browse/MDEV-5540, we have to do it
    # the ugly way.
    file_line { 'debian_increase_mysql_startup_time':
      line    => 'MYSQLD_STARTUP_TIMEOUT=120',
      path    => '/etc/init.d/mysql',
      after   => '^CONF=',
      require => Package[$mysql_server_package_name],
      notify  => Service['mysqld'],
    }
  }

  class { 'mysql::server':
    manage_config_file => false,
    config_file        => $mysql_server_config_file,
    package_name       => $mysql_server_package_name,
    service_name       => $mysql_service_name,
    override_options   => {
      'mysqld' => {
        'bind-address' => $api_eth
      }
    },
    root_password      => $mysql_root_password_real,
    notify             => Service['xinetd'],
  }

  file { $mysql_server_config_file:
    content => template('cloud/database/mysql.conf.erb'),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    notify  => [Service['mysqld'],Exec['clean-mysql-binlog']],
    require => Package[$mysql_server_package_name],
  }

  class { 'mysql::client':
    package_name => $mysql_client_package_name,
  }

  # Haproxy http monitoring
  augeas { 'mysqlchk':
    context => '/files/etc/services',
    changes => [
      'ins service-name after service-name[last()]',
      'set service-name[last()] "mysqlchk"',
      'set service-name[. = "mysqlchk"]/port 9200',
      'set service-name[. = "mysqlchk"]/protocol tcp',
    ],
    onlyif  => 'match service-name[. = "mysqlchk"] size == 0',
    notify  => [ Service['xinetd'], Exec['reload_xinetd'] ]
  }

  file {
    '/etc/xinetd.d/mysqlchk':
      content => template('cloud/database/mysqlchk.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => File['/usr/bin/clustercheck'],
      notify  => [ Service['xinetd'], Exec['reload_xinetd'] ];
    '/usr/bin/clustercheck':
      ensure  => present,
      content => template('cloud/database/clustercheck.erb'),
      mode    => '0755',
      owner   => 'root',
      group   => 'root';
  }

  # The puppet-xinetd module do not correctly reload
  # the configuration on “notify”
  # TODO(Goneri): remove this once https://github.com/puppetlabs/puppetlabs-xinetd/pull/9
  # get merged
  exec{ 'reload_xinetd':
    command     => '/usr/bin/pkill -F /var/run/xinetd.pid --signal HUP',
    refreshonly => true,
    require     => Service['xinetd'],
  }

  exec{'clean-mysql-binlog':
    # first sync take a long time
    command     => "/bin/bash -c '/usr/bin/mysqladmin --defaults-file=/root/.my.cnf shutdown ; /bin/rm  ${::mysql::params::datadir}/ib_logfile*'",
    path        => '/usr/bin',
    notify      => Service['mysqld'],
    refreshonly => true,
    onlyif      => "stat ${::mysql::params::datadir}/ib_logfile0 && test `du -sh ${::mysql::params::datadir}/ib_logfile0 | cut -f1` != '256M'",
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow galera access':
      port   => ['3306', '4567', '4568', '4444'],
      extras => $firewall_settings,
    }
    cloud::firewall::rule{ '100 allow mysqlchk access':
      port   => '9200',
      extras => $firewall_settings,
    }
    cloud::firewall::rule{ '100 allow mysql rsync access':
      port   => '873',
      extras => $firewall_settings,
    }
  }

  @@haproxy::balancermember{$::fqdn:
    listening_service => 'galera_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => '3306',
    options           =>
      inline_template('check inter 2000 rise 2 fall 5 port 9200 <% if @hostname != @galera_master_name -%>backup<% end %>')
  }

  @@haproxy::balancermember{"${::fqdn}-readonly":
    listening_service => 'galera_readonly_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => '3306',
    options           =>
      inline_template('check inter 2000 rise 2 fall 5 port 9200 <% if @hostname == @galera_master_name -%>backup<% end %>')
  }
}
