class timezone::params {
    case $operatingsystem {
        /(Ubuntu|Debian)/: {
            $package_name = "tzdata"
            $localtime = "/etc/localtime"
            $zoneinfo_base = "/usr/share/zoneinfo/"
        }
    }
}
