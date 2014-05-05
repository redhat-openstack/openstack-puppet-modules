# == class fluentd::packages
class fluentd::packages {

    case $::osfamily {
        'redhat': {
            yumrepo { 'treasuredata':
                descr    => 'Treasure Data',
                baseurl  => 'http://packages.treasure-data.com/redhat/$basearch',
                gpgkey   => 'http://packages.treasure-data.com/redhat/RPM-GPG-KEY-td-agent',
                gpgcheck => 1,
            }

            package { 'td-agent':
                ensure  => present,
                require => Yumrepo['treasuredata'],
            }

            user { 'td-agent':
              ensure  => present,
              groups  => 'adm',
              require => Package['td-agent'],
            }
        }
        'debian': {
            apt::source { 'treasure-data':
                location    => "http://packages.treasure-data.com/debian",
                release     => "lucid",
                repos       => "contrib",
                include_src => false,
            }

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
            exec {'add user td-agent to group adm':
                unless  => '/bin/grep -q "adm\S*td-agent" /etc/group',
                command => '/usr/sbin/usermod -aG adm td-agent',
            }
        }
        default: {
            fail("Unsupported osfamily ${::osfamily}")
        }
    }

}
