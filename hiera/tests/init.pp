class { 'hiera':
  datadir   => '/etc/puppetlabs/puppet/hieradata',
  hierarchy => [
    '%{environment}/%{calling_class}',
    '%{environment}',
    'common',
  ],
}
