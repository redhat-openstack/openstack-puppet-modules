# uchiwa::api
# Used for defining APIS
# uchiwa::api { ' API 1':
#  host    => '10.56.5.8',
# }
#
# uchiwa::api { 'API 2':
#  host    => '10.16.1.25',
#  ssl     => true,
#  port    => 7654,
#  user    => 'sensu',
#  pass    => 'saBEnX8PQoyz2LG',
#  path    => '/sensu',
#  timeout => 5000
#}
define uchiwa::api(
  $host     = $title,
  $ssl      = false,
  $insecure = false,
  $port     = 4567,
  $user     = 'sensu',
  $pass     = 'sensu',
  $path     = '',
  $timeout  = 5000
  ) {

  validate_re($name, '^[a-zA-Z0-9_\- .]*$')
  validate_re($host, '^[a-zA-Z0-9_\-.]*$')
  validate_bool($ssl)
  validate_re($port, '^[0-9]*$')
  validate_re($user, '^[a-zA-Z0-9_]*$')
  validate_re($path, '^[a-zA-Z0-9_/]*$')
  validate_bool($insecure)
  validate_re($timeout, '^[0-9]*$')

  datacat_fragment { "uchiwa-api-${name}":
    target  => '/etc/sensu/uchiwa.json',
    data    => {
      api   => ["    {
      \"name\": \"${title}\",
      \"host\": \"${host}\",
      \"port\": ${port},
      \"ssl\": ${ssl},
      \"insecure\": $insecure,
      \"user\": \"${user}\",
      \"pass\": \"${pass}\",
      \"path\": \"${path}\",
      \"timeout\": ${timeout}
    }"],
    host    => $uchiwa::host,
    port    => $uchiwa::port,
    user    => $uchiwa::user,
    pass    => $uchiwa::pass,
    stats   => $uchiwa::stats,
    refresh => $uchiwa::refresh
    },
  }

}