# == class fluentd::service
class fluentd::service (
    $service_ensure = $fluentd::service_ensure,
    $service_enable = $fluentd::service_enable,
) {
    include fluentd::params
    service {"${fluentd::params::service_name}":
        ensure    => $service_ensure,
        enable    => $service_enable,
        hasstatus => true
    }
}
