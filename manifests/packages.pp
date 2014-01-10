# == class fluentd::packages
class fluentd::packages {

    case $::osfamily {
        'redhat': {
            fail('RedHat and CentOS are not supported yet. Waiting for your pullrequest')
        }
        'debian': {

            # http://packages.treasure-data.com/debian/pool/contrib/t/td-agent/
            # TODO: had to disable this part since the Repository does not provide a Key

            #apt::source { 'treasure-data':
            #  location    => "http://packages.treasure-data.com/debian",
            #  release     => "lucid",
            #  repos       => "contrib",
            #  include_src => false,
            #}->
            package{[
                'libxslt1.1',
                'libyaml-0-2',
                'td-agent'
            ]:
                ensure => present,
                }~>
                exec {'add user td-agent to group adm':
                    unless  => 'grep -q "adm\S*td-agent" /etc/group',
                    command => 'usermod -aG adm td-agent',
                }
        }
        default: {
            fail("Unsupported osfamily ${::osfamily}")
        }
    }

}
