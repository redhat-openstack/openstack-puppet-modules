require 'spec_helper'
describe 'common' do

  describe 'class common' do

    context 'default options with supported OS' do
      let(:facts) { { :osfamily => 'RedHat' } }

      it { should contain_class('common') }
    end

    context 'default options with unsupported osfamily, Gentoo, should fail' do
      let(:facts) { { :osfamily => 'Gentoo' } }
      it do
        expect {
          should contain_class('common')
        }.to raise_error(Puppet::Error,/Supported OS families are Debian, RedHat, Solaris, and Suse. Detected osfamily is Gentoo./)
      end
    end

    describe 'managing root password' do
      context 'manage_root_password => true with default root_password' do
        let(:facts) { { :osfamily => 'RedHat' } }
        let(:params) { { :manage_root_password => true } }

        it { should contain_class('common') }

        it {
          should contain_user('root').with({
            'password' => '$1$cI5K51$dexSpdv6346YReZcK2H1k.',
          })
        }
      end

      context 'manage_root_password => true and root_password => foo' do
        let(:facts) { { :osfamily => 'RedHat' } }
        let(:params) do
          { :manage_root_password => true,
            :root_password        => 'foo',
          }
        end

        it { should contain_class('common') }

        it {
          should contain_user('root').with({
            'password' => 'foo',
          })
        }
      end
    end

    describe 'managing /opt/$lanana' do
      context 'create_opt_lsb_provider_name_dir => true and lsb_provider_name => UNSET [default]' do
        let(:facts) { { :osfamily => 'RedHat' } }
        let(:params) do
          { :create_opt_lsb_provider_name_dir => true,
            :lsb_provider_name => 'UNSET',
          }
        end

        it { should contain_class('common') }

        it { should_not contain_file('/opt/UNSET') }
      end

      context 'create_opt_lsb_provider_name_dir => true and lsb_provider_name => foo' do
        let(:facts) { { :osfamily => 'RedHat' } }
        let(:params) do
          { :create_opt_lsb_provider_name_dir => true,
            :lsb_provider_name                => 'foo',
          }
        end

        it { should contain_class('common') }

        it {
          should contain_file('/opt/foo').with({
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          })
        }
      end
    end
  end
end
