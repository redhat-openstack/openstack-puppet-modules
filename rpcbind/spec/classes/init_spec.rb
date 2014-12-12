require 'spec_helper'
describe 'rpcbind' do

  describe 'with default values for parameters' do
    context 'on unsupported osfamily' do
      let(:facts) { { :osfamily => 'Solaris' } }

      it 'should fail' do
        expect {
          should contain_class('rpcbind')
        }.to raise_error(Puppet::Error,/^rpcbind supports osfamilies Debian, RedHat, and Suse. Detected osfamily is <Solaris>/)
      end
    end

    context 'on supported osfamily Debian with unsupported lsbdistid' do
      let(:facts) do
        { :lsbdistid => 'Unsupported',
          :osfamily => 'Debian',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('rpcbind')
        }.to raise_error(Puppet::Error,/^rpcbind on osfamily Debian supports lsbdistid Debian and Ubuntu. Detected lsbdistid is <Unsupported>./)
      end
    end

    context 'on supported osfamily Suse with unsupported lsbmajdistrelease' do
      let(:facts) do
        { :lsbmajdistrelease => '9',
          :osfamily          => 'Suse',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('rpcbind')
        }.to raise_error(Puppet::Error,/^rpcbind on osfamily Suse supports lsbmajdistrelease 10, 11, and 12. Detected lsbmajdistrelease is <9>./)
      end
    end
  end

  describe 'package resource' do
    context 'with default params on osfamily Suse 10' do
      let(:facts) { { :osfamily => 'Suse', :lsbmajdistrelease => '10' } }

      it {
        should contain_package('portmap').with({
          'ensure' => 'installed',
        })
      }
    end

    context 'with default params on osfamily Suse 11' do
      let(:facts) { { :osfamily => 'Suse', :lsbmajdistrelease => '11' } }

      it {
        should contain_package('rpcbind').with({
          'ensure' => 'installed',
        })
      }
    end

    context 'with default params on osfamily Suse 12' do
      let(:facts) { { :osfamily => 'Suse', :lsbmajdistrelease => '12' } }

      it {
        should contain_package('rpcbind').with({
          'ensure' => 'installed',
        })
      }
    end

    context 'with default params on osfamily RedHat' do
      let(:facts) { { :osfamily => 'RedHat' } }

      it {
        should contain_package('rpcbind').with({
          'ensure' => 'installed',
        })
      }
    end

    context 'with default params on Debian' do
      let(:facts) do
        { :lsbdistid => 'Debian',
          :osfamily => 'Debian',
        }
      end

      it {
        should contain_package('rpcbind').with({
          'ensure' => 'installed',
        })
      }
    end

    context 'with default params on Ubuntu' do
      let(:facts) do
        { :lsbdistid => 'Ubuntu',
          :osfamily => 'Debian',
        }
      end

      it {
        should contain_package('rpcbind').with({
          'ensure' => 'installed',
        })
      }
    end

    context 'with ensure absent' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :package_ensure => 'absent' } }

      it {
        should contain_package('rpcbind').with({
          'ensure' => 'absent',
        })
      }
    end

    context 'with supplied string for package name' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :package_name => 'my_rpcbind' } }

      it {
        should contain_package('my_rpcbind').with({
          'ensure' => 'installed',
        })
      }
    end

    context 'with supplied array for package name' do
      let(:facts) { { :osfamily => 'RedHat' } }
      packages = [ 'rpcbind', 'rpcbindfoo', 'rpcbindbar' ]
      let(:params) { { :package_name => packages } }

      packages.each do |pkg|
        it {
          should contain_package(pkg).with({
            'ensure' => 'installed',
          })
        }
      end
    end
  end

  describe 'service resource' do
    context 'with default params on osfamily RedHat' do
      let(:facts) { { :osfamily => 'RedHat' } }

      it {
        should contain_service('rpcbind_service').with({
          'ensure' => 'running',
          'name'   => 'rpcbind',
          'enable' => true,
        })
      }
    end

    context 'with default params on Debian' do
      let(:facts) do
        { :lsbdistid => 'Debian',
          :osfamily => 'Debian',
        }
      end

      it {
        should contain_service('rpcbind_service').with({
          'ensure' => 'running',
          'name'   => 'rpcbind',
          'enable' => true,
        })
      }
    end

    context 'with default params on Ubuntu' do
      let(:facts) do
        { :lsbdistid => 'Ubuntu',
          :osfamily => 'Debian',
        }
      end

      it {
        should contain_service('rpcbind_service').with({
          'ensure' => 'running',
          'name'   => 'rpcbind-boot',
          'enable' => true,
        })
      }
    end

    context 'with default params on Suse 10' do
      let(:facts) do
        { :osfamily          => 'Suse',
          :lsbmajdistrelease => '10',
        }
      end

      it {
        should contain_service('rpcbind_service').with({
          'ensure' => 'running',
          'name'   => 'portmap',
          'enable' => true,
        })
      }
    end

    context 'with default params on Suse 11' do
      let(:facts) do
        { :osfamily          => 'Suse',
          :lsbmajdistrelease => '11',
        }
      end

      it {
        should contain_service('rpcbind_service').with({
          'ensure' => 'running',
          'name'   => 'rpcbind',
          'enable' => true,
        })
      }
    end

    context 'with default params on Suse 12' do
      let(:facts) do
        { :osfamily          => 'Suse',
          :lsbmajdistrelease => '12',
        }
      end

      it {
        should contain_service('rpcbind_service').with({
          'ensure' => 'running',
          'name'   => 'rpcbind',
          'enable' => true,
        })
      }
    end

    context 'with ensure stopped' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :service_ensure => 'stopped' } }

      it {
        should contain_service('rpcbind_service').with({
          'ensure' => 'stopped',
          'name'   => 'rpcbind',
          'enable' => true,
        })
      }
    end

    context 'with supplied string for service name' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :service_name => 'my_rpcbind' } }

      it {
        should contain_service('rpcbind_service').with({
          'ensure' => 'running',
          'name'   => 'my_rpcbind',
          'enable' => true,
        })
      }
    end

    context 'with enable false' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :service_enable => false } }

      it {
        should contain_service('rpcbind_service').with({
          'ensure' => 'running',
          'name'   => 'rpcbind',
          'enable' => false,
        })
      }
    end
  end
end
