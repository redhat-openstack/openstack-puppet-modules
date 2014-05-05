# yum.pp 

# Class: fluentd::install_repo::yum ()
#
#
class fluentd::install_repo::yum (
    $key = $fluentd::params::yum_key_url,
    ) {
    # resources
    file { "/etc/yum.repos.d/td.repo":
        ensure => file,
        content => template('fluentd/treasuredata_yum_repo.erb'),
        mode => '0644'
    }
    exec { "import_td_yum_key":
        command => "/bin/rpm --import ${key} && touch /var/tmp/import_td_yum_key",
        creates => '/var/tmp/import_td_yum_key',
        #path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
        refreshonly => true
    } 
}