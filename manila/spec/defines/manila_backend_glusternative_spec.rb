require 'spec_helper'

describe 'manila::backend::glusternative' do

  shared_examples_for 'glusternative volume driver' do
    let(:title) {'fuse'}

    let :params do
      {
        :glusterfs_servers                    => 'remoteuser@volserver',
        :glusterfs_native_path_to_private_key => '/etc/glusterfs/glusterfs.pem',
        :glusterfs_volume_pattern             => 'manila-share-volume-\d+$',
      }
    end

    describe 'glusternative share driver' do
      it 'configures glusterfs fuse/native share driver' do
        is_expected.to contain_manila_config('fuse/share_backend_name').with(
          :value => 'fuse')
        is_expected.to contain_manila_config('fuse/share_driver').with_value(
          'manila.share.drivers.glusterfs_native.GlusterfsNativeShareDriver')
        params.each_pair do |config,value|
          is_expected.to contain_manila_config("fuse/#{config}").with_value( value )
        end
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({ :osfamily => 'Debian' })
    end

    it_configures 'glusternative volume driver'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge({ :osfamily => 'RedHat' })
    end

    it_configures 'glusternative volume driver'
  end

end
