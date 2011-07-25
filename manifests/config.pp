class timezone::config {
    file { $timezone::params::localtime:
        require => Class['timezone::install'],
        ensure  => "${timezone::params::zoneinfo_base}${timezone::timezone}",
    }
}
