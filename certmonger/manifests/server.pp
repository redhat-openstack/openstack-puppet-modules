class certmonger::server {

  package { 'certmonger': ensure => present }

  service { 'certmonger':
    name       => 'certmonger',
    ensure     => running,
    enable     => true,
    require    => Package['certmonger'],
  }
}
