require 'spec_helper'
describe 'types::mount' do

  context 'mount with bare minimum specified' do
    let(:title) { '/mnt' }
    let(:params) do
      { :device => '/dev/dvd',
        :fstype => 'iso9660',
      }
    end
    let(:facts) { { :osfamily => 'RedHat' } }

    it {
      should contain_mount('/mnt').with({
        'ensure' => 'mounted',
        'name'   => '/mnt',
        'atboot' => true,
        'device' => '/dev/dvd',
        'fstype' => 'iso9660',
      })
    }
  end

  context 'mount with all options specified' do
    let(:title) { '/mnt' }
    let(:params) do
      { :device      => '/dev/fiction',
        :fstype      => 'iso9660',
        :ensure      => 'absent',
        :atboot      => false,
        :blockdevice => '/dev/blockdevice',
        :dump        => '1',
        :options     => 'ro',
        :pass        => '1',
        :provider    => 'customprovider',
        :remounts    => true,
      }
    end
    let(:facts) { { :osfamily => 'RedHat' } }

    it {
      should contain_mount('/mnt').with({
        'ensure'      => 'absent',
        'atboot'      => false,
        'device'      => '/dev/fiction',
        'fstype'      => 'iso9660',
        'name'        => '/mnt',
        'blockdevice' => '/dev/blockdevice',
        'dump'        => '1',
        'options'     => 'ro',
        'pass'        => '1',
        'provider'    => 'customprovider',
        'remounts'    => true,
      })
    }
  end

  context 'mount with invalid ensure' do
    let(:title) { 'invalid' }
    let(:params) do
      { :device      => '/dev/fiction',
        :fstype      => 'iso9660',
        :target      => '/mnt',
        :ensure      => '!invalid',
      }
    end

    it 'should fail' do
      expect {
        should contain_class('types')
      }.to raise_error(Puppet::Error,/types::mount::invalid::ensure is invalid and does not match the regex./)
    end
  end

  describe 'with \'options\' parameter set to \'defaults\'' do
    context 'on osfamily Solaris' do
      let(:title) { '/mnt' }
      let(:params) do
        { :device      => '/dev/fiction',
          :fstype      => 'iso9660',
          :options     => 'defaults',
        }
      end
      let(:facts) { { :osfamily => 'Solaris' } }

      it {
        should contain_mount('/mnt').with({
          'ensure'      => 'mounted',
          'device'      => '/dev/fiction',
          'fstype'      => 'iso9660',
          'options'     => '-',
        })
      }
    end

    context 'on osfamily that is not Solaris' do
      let(:title) { '/mnt' }
      let(:params) do
        { :device      => '/dev/fiction',
          :fstype      => 'iso9660',
          :options     => 'defaults',
        }
      end
      let(:facts) { { :osfamily => 'Debian' } }

      it {
        should contain_mount('/mnt').with({
          'ensure'      => 'mounted',
          'device'      => '/dev/fiction',
          'fstype'      => 'iso9660',
          'options'     => 'defaults',
        })
      }
    end
  end
end
