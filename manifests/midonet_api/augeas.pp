# == Class: midonet::midonet_api::augeas
#
# Make sure augeas is installed before install tomcat

class midonet::midonet_api::augeas {

    case $::osfamily {
        'Debian': {
            package {'libaugeas-ruby':
                ensure => present
            }
        }
        'RedHat': {
            package {'deltarpm':
                ensure => present
            } ->
            package {'augeas':
                ensure => present
            } ->
            package {'augeas-devel':
                ensure => present
            } ->
            exec {'/usr/bin/gem install ruby-augeas': }
        }
        default: {
            fail('Operating System not supported by this module')
        }
    }
}
