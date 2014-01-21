class fluentd::packages {

  case $::osfamily {
    'redhat': {
      fail("RedHat and CentOS are not supported yet. Waiting for your pullrequest")
    }
    'debian': {

      file { '/tmp/packages.treasure-data.com.key':
        ensure => file,
        source => 'puppet:///modules/fluentd/packages.treasure-data.com.key'
      }->
      exec { "import gpg key Treasure Data":
        command => "/bin/cat /tmp/packages.treasure-data.com.key | apt-key add -",
        unless  => "/usr/bin/apt-key list | grep -q 'Treasure Data'",
        notify  => Class['::apt::update'],
      }->
      package{[
        'libxslt1.1',
        'libyaml-0-2',
        'td-agent'
      ]:
        ensure => present,
      }~>
      exec {"add user td-agent to group adm":
        unless => "grep -q 'adm\\S*td-agent' /etc/group",
        command => "usermod -aG adm td-agent",
      }
    }
    default: {
      fail("Unsupported osfamily ${::osfamily}")
    }
  }


}