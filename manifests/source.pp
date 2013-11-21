# Define: name
# Parameters:
# arguments
#
define name ($config) {
  file { $::name:
        path    => "/etc/td-agent/config.d/$::name.conf",
        ensure  => file,
        require => Package['td-agent'],
        content => template("fluentd/source.erb"),
  }
}