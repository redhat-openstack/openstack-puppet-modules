require 'spec_helper'

describe 'manila::backend::glusternfs' do

  shared_examples_for 'glusternfs volume driver' do
    let(:title) {'gnfs'}

    let :params do
      {
        :glusterfs_target              => 'remoteuser@volserver:volid',
        :glusterfs_mount_point_base    => '$state_path/mnt',
        :glusterfs_nfs_server_type     => 'gluster',
        :glusterfs_path_to_private_key => '/etc/glusterfs/glusterfs.pem',
        :glusterfs_ganesha_server_ip   => '127.0.0.1',
      }
    end

    describe 'glusternfs share driver' do
      it 'configures gluster nfs/ganesha share driver' do
        is_expected.to contain_manila_config('gnfs/share_backend_name').with(
          :value => 'gnfs')
        is_expected.to contain_manila_config('gnfs/share_driver').with_value(
          'manila.share.drivers.glusterfs.GlusterfsShareDriver')
        params.each_pair do |config,value|
          is_expected.to contain_manila_config("gnfs/#{config}").with_value( value )
        end
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({ :osfamily => 'Debian' })
    end

    it_configures 'glusternfs volume driver'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge({ :osfamily => 'RedHat' })
    end

    it_configures 'glusternfs volume driver'
  end

end
