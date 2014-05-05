# Class: fluentd::params
#
#
class fluentd::params {
    $package_name = 'td-agent'
    $package_ensure = 'installed'
    $install_repo = false
    $service_ensure = 'running'
    $service_enable = false
    $service_name = 'td-agent'
    $yum_key_url = "http://packages.treasure-data.com/redhat/RPM-GPG-KEY-td-agent"
}