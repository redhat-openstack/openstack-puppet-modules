require 'spec_helper'

describe 'manila::share::glusterfs' do

  shared_examples_for 'glusterfs share driver' do
    let :params do
      {
        :glusterfs_volumes_config    => '/etc/manila/glusterfs_volumes',
        :glusterfs_mount_point_base  => '$state_path/mnt',
      }
    end

    it 'configures glusterfs share driver' do
      is_expected.to contain_manila_config('DEFAULT/share_driver').with_value(
        'manila.share.drivers.glusterfs.GlusterfsShareDriver')
      is_expected.to contain_manila_config('DEFAULT/glusterfs_volumes_config').with_value(
        '/etc/manila/glusterfs_volumes')
      is_expected.to contain_manila_config('DEFAULT/glusterfs_mount_point_base').with_value(
        '$state_path/mnt')
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'glusterfs share driver'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'glusterfs share driver'
  end

end
