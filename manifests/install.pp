class timezone::install {
    package { $timezone::params::package_name:
        ensure => present,
    }
}
