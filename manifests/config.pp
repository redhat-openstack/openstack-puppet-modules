class timezone::config {
    file { $timezone::params::localtime:
        require => Package['tzdata'],
        ensure  => "${timezone::params::zoneinfo_base}${timezone::timezone}",
    }
}
