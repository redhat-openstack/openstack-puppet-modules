require 'spec_helper'
describe 'nfs' do

  describe 'on unsupported' do
    context 'osfamily' do
      let(:facts) { { :osfamily => 'Unsupported' } }

      it 'should fail' do
        expect {
          should raise_error(Puppet::Error, /^nfs module only supports osfamilies Debian, RedHat, Solaris and Suse, and <Unsupported> was detected./)
        }
      end
    end

    context 'version of EL' do
      let :facts do
        { :osfamily          => 'RedHat',
          :lsbmajdistrelease => '4',
        }
      end

      it 'should fail' do
        expect {
          should raise_error(Puppet::Error, /^nfs module only supports EL 5, 6 and 7 and lsbmajdistrelease was detected as <4>./)
        }
      end
    end

    context 'version of Suse' do
      let :facts do
        { :osfamily          => 'Suse',
          :lsbmajdistrelease => '9',
        }
      end

      it 'should fail' do
        expect {
          should raise_error(Puppet::Error, /^nfs module only supports Suse 10 and 11 and lsbmajdistrelease was detected as <9>./)
        }
      end
    end

    context 'lsbdistid of osfamily Debian' do
      let :facts do
        { :osfamily  => 'Debian',
          :lsbdistid => 'unsupported',
        }
      end

      it 'should fail' do
        expect {
          should raise_error(Puppet::Error, /^nfs module only supports lsbdistid Debian and Ubuntu of osfamily Debian. Detected lsbdistid is <unsupported>./)
        }
      end
    end

    context 'version of Solaris' do
      let :facts do
        { :osfamily          => 'Solaris',
          :kernelrelease => '5.8',
        }
      end

      it 'should fail' do
        expect {
          should raise_error(Puppet::Error, /^nfs module only supports Solaris 5.10 and 5.11 and kernelrelease was detected as <5.8>./)
        }
      end
    end
  end

  platforms = {
    'debian' =>
      { :osfamily        => 'Debian',
        :lsbdistid       => 'Debian',
        :release         => '6',
        :include_idmap   => false,
        :include_rpcbind => true,
        :packages        => 'nfs-common',
        :service         => 'nfs-common',
      },
    'ubuntu' =>
      { :osfamily        => 'Debian',
        :lsbdistid       => 'Ubuntu',
        :release         => '12',
        :include_idmap   => false,
        :include_rpcbind => true,
        :packages        => 'nfs-common',
      },
    'el5' =>
      { :osfamily        => 'RedHat',
        :release         => '5',
        :include_idmap   => true,
        :include_rpcbind => false,
        :packages        => 'nfs-utils',
        :service         => 'nfs',
      },
    'el6' =>
      { :osfamily        => 'RedHat',
        :release         => '6',
        :include_idmap   => true,
        :include_rpcbind => true,
        :packages        => 'nfs-utils',
        :service         => 'nfs',
      },
    'el7' =>
      { :osfamily        => 'RedHat',
        :release         => '7',
        :include_idmap   => true,
        :include_rpcbind => true,
        :packages        => 'nfs-utils',
        :service         => false,
      },
    'solaris10' =>
      { :osfamily        => 'Solaris',
        :kernelrelease   => '5.10',
        :include_idmap   => false,
        :include_rpcbind => false,
        :packages        => ['SUNWnfsckr','SUNWnfscr','SUNWnfscu','SUNWnfsskr','SUNWnfssr','SUNWnfssu'],
        :service         => 'nfs/client',
      },
    'solaris11' =>
      { :osfamily        => 'Solaris',
        :kernelrelease   => '5.11',
        :include_idmap   => false,
        :include_rpcbind => false,
        :packages        => ['service/file-system/nfs','system/file-system/nfs'],
        :service         => 'nfs/client',
      },
    'suse10' =>
      { :osfamily        => 'Suse',
        :release         => '10',
        :include_idmap   => true,
        :include_rpcbind => false,
        :packages        => 'nfs-utils',
        :service         => 'nfs',
      },
    'suse11' =>
      { :osfamily        => 'Suse',
        :release         => '11',
        :include_idmap   => true,
        :include_rpcbind => false,
        :packages        => 'nfs-client',
        :service         => 'nfs',
      },
  }
  describe 'with default values for parameters' do
    platforms.sort.each do |k,v|
      context "where osfamily is <#{v[:osfamily]}> lsbdistid is <#{v[:lsbdistid]}> kernelrelease is <#{v[:kernelrelease]}> and release is <#{v[:release]}>" do
        let :facts do
          { :osfamily          => v[:osfamily],
            :lsbmajdistrelease => v[:release],
            :lsbdistid         => v[:lsbdistid],
            :kernelrelease     => v[:kernelrelease],
          }
        end

        # This is to build an array such that it will be accepted by the
        # service's subscribe attribute.
        service_subscribe = Array.new

        it { should compile.with_all_deps }

        if v[:include_idmap] == true
          it { should contain_class('nfs::idmap') }
        else
          it { should_not contain_class('nfs::idmap') }
        end

        if v[:include_rpcbind] == true
          it { should contain_class('rpcbind') }
        else
          it { should_not contain_class('rpcbind') }
        end

        if v[:packages].class == Array
          v[:packages].each do |pkg|
            it {
              should contain_package(pkg).with({
                'ensure' => 'present',
              })
            }
            # Building the array of Packages for service's subscribe attribute.
            service_subscribe << "Package[#{pkg}]"
          end

          if v[:service]
            it {
              should contain_service('nfs_service').with({
                'ensure'    => 'running',
                'name'      => v[:service],
                'enable'    => true,
                'subscribe' => service_subscribe,
              })
            }
          end
        else
          it {
            should contain_package(v[:packages]).with({
              'ensure' => 'present',
            })
          }

          if v[:service]
            it {
              should contain_service('nfs_service').with({
                'ensure'    => 'running',
                'name'      => v[:service],
                'enable'    => true,
                'subscribe' => "Package[#{v[:packages]}]",
              })
            }
          end
        end
      end
    end
  end

  describe 'with hiera_hash parameter specified' do
    context 'as a non-boolean' do
      let(:params) { { :hiera_hash => 'not_a_boolean' } }
      let(:facts) do
        { :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
        }
      end

      it 'should fail' do
        expect { should raise_error(Puppet::Error) }
      end
    end

    ['true',true].each do |value|
      context "as #{value}" do
        let(:params) { { :hiera_hash => value } }
        let(:facts) do
          { :osfamily          => 'RedHat',
            :lsbmajdistrelease => '6',
          }
        end

        it { should compile.with_all_deps }

        it { should contain_class('nfs') }
      end
    end

    ['false',false].each do |value|
      context "as #{value}" do
        let(:params) { { :hiera_hash => value } }
        let(:facts) do
          { :osfamily          => 'RedHat',
            :lsbmajdistrelease => '6',
          }
        end

        it { should compile.with_all_deps }

        it { should contain_class('nfs') }
      end
    end
  end

  context 'with the mounts parameter set' do
    let :facts do
      { :osfamily          => 'RedHat',
        :lsbmajdistrelease => '6',
      }
    end

    let :params do
      { :mounts => {
        '/var/foo' => {
          'ensure' => 'present',
          'fstype' => 'nfs',
          'device' => '/net/foo',
        }
      } }
    end

    it {
      should contain_mount('/var/foo').with({
        'ensure' => 'present',
        'fstype' => 'nfs',
        'device' => '/net/foo',
      })
    }
  end

  context 'with the mounts parameter set to an incorrect type' do
    let :facts do
      { :osfamily          => 'RedHat',
        :lsbmajdistrelease => '6',
      }
    end

    let :params do
      { :mounts => 'i should be a hash' }
    end

    it 'should fail' do
      expect {
        should raise_error(Puppet::Error)
      }
    end
  end
end
