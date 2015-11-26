require 'spec_helper_acceptance'

describe 'midonet all-in-one' do

  context 'default parameters' do
    it 'should work with no errors' do
      pp = <<-EOS
      if empty($::augeasversion) {
        $augeasversion = '1.0.0'
      }
      class { 'midonet': } ->
        exec { "/sbin/ip tuntap add mode tap testgateway": } ->
        exec { "/usr/bin/midonet-cli -e 'create router name \\"MidoNet Provider Router\\"'": } ->
        midonet_gateway { $::hostname:
        ensure          => present,
        midonet_api_url => 'http://127.0.0.1:8080/midonet-api',
        username        => 'admin',
        password        => 'admin',
        interface       => 'testgateway',
        local_as        => '64512',
        bgp_port        => {'port_address' => '198.51.100.2', 'net_prefix' => '198.51.100.0', 'net_length' => '30'},
        remote_peers    => [{ 'as' => '64513', 'ip' => '198.51.100.1'},
                            { 'as' => '64513', 'ip' => '203.0.113.1'}],
        advertise_net   => [{ 'net_prefix' => '192.0.2.0', 'net_length' => '24' }]
      }
      EOS

      # Run it twice for test the idempotency
      apply_manifest(pp)
      apply_manifest(pp)
    end
  end
end
