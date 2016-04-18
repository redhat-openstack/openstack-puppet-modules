node default {

  # Qpid Dispatch Router common class
  class { '::qdr' :
    # Currently no mandatory parameters
  }

  # Create a listener type
#  qdr_listener { 'GoodListener' :
#    ensure          => present,
#    addr            => '127.0.0.1',
#    port            => '6789',
#    role            => 'normal',
#    auth_peer       => true,
#    sasl_mechanisms => 'ANONYMOUS,DIGEST-MD5,EXTERNAL,PLAIN',
#  }

  # Create a user for sasl db
#  qdr_user { 'SaslUser' :
#    ensure           => present,
#    password         => 'testpw',
#    file             => '/var/lib/qdrouterd/qdrouterd.sasldb',  
#  }
}
