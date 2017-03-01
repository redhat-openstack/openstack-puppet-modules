# NOTE: This requires that the directory /tmp/nssdb already exists

# Create a test database owned by the user rcrit
nssdb::create {'test':
  owner_id => 'rcrit',
  group_id => 'rcrit',
  password => 'test',
  cacert   => '/etc/ipa/ca.crt',
  catrust  => 'CT,,',
  basedir  => '/tmp/nssdb',
}

# Add a certificate and private key from PEM fiels
nssdb::add_cert_and_key {'test':
  cert     => '/tmp/cert.pem',
  key      => '/tmp/key.pem',
  nickname => 'test',
  basedir  => '/tmp/nssdb',
}

# You can confirm that things are loaded properly with:
#
# List the certs:
# certutil -L -d /tmp/nssdb/test
#
# Verify the cert:
# certutil -V -u V -d /tmp/nssdb/test -n test
