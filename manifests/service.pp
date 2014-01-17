# == class fluentd::service
class fluentd::service {
    service {
        'td-agent':
            ensure    => running,
            enable    => true,
            hasstatus => true;
    }
}
