require 'spec_helper'

describe 'uchiwa' do
  let(:facts) { 
    { 
      :osfamily => 'RedHat',
      :concat_basedir => '/dne',
     }
  }
  
  it 'should compile' do should create_class('uchiwa') end
  it { should contain_class('uchiwa::config')}


  context 'package' do
    context 'defaults' do
      it { should create_class('uchiwa::repo::yum') }
      it { should contain_package('uchiwa').with_ensure('latest') }
      it { should contain_file('/etc/sensu/uchiwa.json') }
    end

    context 'setting version' do
      let(:params) { {
        :version      => '0.1.5',
      } }

      it { should contain_package('uchiwa').with(
        :ensure => '0.1.5'
      ) }
    end

    context 'repos' do

      context 'ubuntu' do
        let(:facts) { 
          { 
            :osfamily => 'Debian',
            :fqdn => 'testhost.domain.com',
            :concat_basedir => '/dne' 
          } 
        }

        context 'with puppet-apt installed' do
          let(:pre_condition) { [ 'define apt::source ($ensure, $location, $release, $repos, $include_src, $key, $key_source) {}' ] }

          context 'default' do
            it { should contain_apt__source('sensu').with(
              :ensure      => 'present',
              :location    => 'http://repos.sensuapp.org/apt',
              :release     => 'sensu',
              :repos       => 'main',
              :include_src => false,
              :key         => '7580C77F',
              :key_source  => 'http://repos.sensuapp.org/apt/pubkey.gpg',
              :before      => 'Package[uchiwa]'
            ) }
          end

          context 'unstable repo' do
            let(:params) { { :repo => 'unstable' } }
            it { should contain_apt__source('sensu').with_repos('unstable') }
          end

          context 'override repo url' do
            let(:params) { { :repo_source => 'http://repo.mydomain.com/apt' } }
            it { should contain_apt__source('sensu').with( :location => 'http://repo.mydomain.com/apt') }

            it { should_not contain_apt__key('sensu').with(
              :key         => '7580C77F',
              :key_source  => 'http://repo.mydomain.com/apt/pubkey.gpg'
            ) }
          end

          context 'override key ID and key source' do
            let(:params) { { :repo_key_id => 'FFFFFFFF', :repo_key_source => 'http://repo.mydomina.com/apt/pubkey.gpg' } }

            it { should_not contain_apt__key('sensu').with(
              :key         => 'FFFFFFFF',
              :key_source  => 'http://repo.mydomain.com/apt/pubkey.gpg'
            ) }
          end

          context 'install_repo => false' do
            let(:params) { { :install_repo => false, :repo => 'main' } }
            it { should_not contain_apt__source('sensu') }

            it { should_not contain_apt__key('sensu').with(
              :key         => '7580C77F',
              :key_source  => 'http://repos.sensuapp.org/apt/pubkey.gpg'
            ) }
          end
        end

        context 'without puppet-apt installed' do
          it { expect { should raise_error(Puppet::Error) } }
        end
      end

      context 'redhat' do
        let(:facts) { { :osfamily => 'RedHat', :operatingsystemmajrelease => '6',:concat_basedir => '/dne', } }

        context 'default' do
          it { should contain_yumrepo('sensu').with(
            :enabled   => 1,
            :baseurl   => 'http://repos.sensuapp.org/yum/el/6/$basearch/',
            :gpgcheck  => 0,
            :before    => 'Package[uchiwa]'
          ) }
        end

        context 'unstable repo' do
          let(:params) { { :repo => 'unstable' } }
          it { should contain_yumrepo('sensu').with(:baseurl => 'http://repos.sensuapp.org/yum-unstable/el/6/$basearch/' )}
        end

        context 'override repo url' do
          let(:params) { { :repo_source => 'http://repo.mydomain.com/yum' } }
          it { should contain_yumrepo('sensu').with( :baseurl => 'http://repo.mydomain.com/yum') }
        end

        context 'install_repo => false' do
          let(:params) { { :install_repo => false } }
          it { should_not contain_yumrepo('sensu') }
        end
      end
    end

  end

end