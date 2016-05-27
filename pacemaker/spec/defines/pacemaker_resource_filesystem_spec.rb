require 'spec_helper'

describe 'pacemaker::new::resource::filesystem', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:title) { '/my/fs' }

      let(:params) do
        {
            :device => '/dev/my',
            :directory => '/mnt/my',
        }
      end

      context 'with default parameters' do

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_pacemaker__new__resource__filesystem('/my/fs') }

        parameters = {
            :ensure => 'present',
            :primitive_type => 'Filesystem',
            :primitive_provider => 'heartbeat',
            :primitive_class => 'ocf',
            :parameters => {
                'device' => '/dev/my',
                'directory' => '/mnt/my',
            },
        }

        it { is_expected.to contain_pacemaker_resource('fs_dev_my').with(parameters) }

      end

      context 'with custom parameters' do

        let(:params) do
          {
              :ensure => 'absent',
              :device => '/dev/my',
              :directory => '/mnt/my',
              :fstype => 'ext3',
              :fsoptions => 'noatime',
              :additional => {
                  'fsoptions' => 'noatime,noauto',
              },

              :metadata => {
                  'resource-stickiness' => '200',
              },
              :operations => {
                  'monitor' => {
                      'interval' => '10',
                  },
              },
              :complex_type => 'clone',
              :complex_metadata => {
                  'interleave' => true,
              },

              :primitive_class => 'ocf',
              :primitive_provider => 'my',
              :primitive_type => 'fs',
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_pacemaker__new__resource__filesystem('/my/fs') }

        parameters = {
            :ensure => 'absent',
            :primitive_type => 'fs',
            :primitive_provider => 'my',
            :primitive_class => 'ocf',
            :parameters => {
                'device' => '/dev/my',
                'directory' => '/mnt/my',
                'fstype' => 'ext3',
                'fsoptions' => 'noatime,noauto',
            },
            :metadata => {
                'resource-stickiness' => '200',
            },
            :operations => {
                'monitor' => {
                    'interval' => '10',
                },
            },
            :complex_type => 'clone',
            :complex_metadata => {
                'interleave' => true,
            },
        }

        it { is_expected.to contain_pacemaker_resource('fs_dev_my').with(parameters) }

      end

    end
  end
end

