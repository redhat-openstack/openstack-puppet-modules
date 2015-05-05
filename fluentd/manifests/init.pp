# == class fluentd
class fluentd (
    $version = '1',
    $package_name = $fluentd::params::package_name,
    $install_repo = $fluentd::params::install_repo,
    $package_ensure = $fluentd::params::package_ensure,
    $service_enable = $fluentd::params::service_enable,
    $service_ensure = $fluentd::params::service_ensure,
    $service_name = $fluentd::params::service_name
) inherits fluentd::params {
    # fluentd vs td-agent
    $product_name = $service_name

    class{'fluentd::packages': }
    class{'fluentd::config': }
    class{'fluentd::service': }

    validate_bool($install_repo, $service_enable)
    
    Class['Fluentd::Packages'] -> Class['Fluentd::Config'] -> Class['Fluentd::Service']
}
