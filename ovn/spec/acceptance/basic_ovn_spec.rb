require 'spec_helper_acceptance'

describe 'basic ovn deployment' do

  context 'default parameters' do
    pp= <<-EOS
    include ::openstack_integration
    include ::openstack_integration::repos

    # TODO: use rdo-ovn repository once available
    if $::osfamily == 'RedHat' {
      yumrepo { 'dpdk-snapshot':
        enabled    => '1',
        baseurl    => 'https://copr-be.cloud.fedoraproject.org/results/pmatilai/dpdk-snapshot/epel-7-x86_64/',
        descr      => 'Repository for dpdk-snapshot',
        mirrorlist => 'absent',
        gpgcheck   => '1',
        gpgkey     => 'https://copr-be.cloud.fedoraproject.org/results/pmatilai/dpdk-snapshot/pubkey.gpg',
        notify     => Exec[yum_refresh],
      }
    }
    include ::ovn::northd
    class { '::ovn::controller':
      ovn_remote   => 'tcp:127.0.0.1:6642',
      ovn_encap_ip => '127.0.0.1',
    }
    EOS

    it 'should work with no errors' do
      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe 'test openvswitch-ovn CLI' do
      it 'list virtual ports' do
        expect(shell('ovn-nbctl show').exit_code).to be_zero
      end
    end
  end

end
