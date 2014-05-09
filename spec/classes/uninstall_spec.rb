require 'spec_helper'

describe 'kibana3', :type => :class do
  ['Debian', 'RedHat'].each do |system|
    let :facts do
      {
        :concat_basedir         => '/dne',
        :osfamily               => system,
        :operatingsystemrelease => '12.04',
      }
    end

    describe "uninstall on #{system}" do
      context 'with defaults' do
        let (:params) {{ :ensure => 'absent' }}
        it { should compile }
        it { should contain_package('git') \
          .with_ensure('absent')
        }
        it { should contain_class('apache') \
          .with_package_ensure('absent')
        }
        it { should contain_apache__vhost('kibana3') \
          .with(
            'ensure'  => 'absent',
            'docroot' => '/opt/kibana3/src'
          ) }
        it { should contain_file('/opt/kibana3') \
          .with_ensure('absent')
        }
        it { should contain_file('/opt/kibana3/src/config.js') \
          .with_ensure('absent')
        }
      end

      context 'without git' do
        let (:params) {{ :ensure => 'absent', :manage_git => false }}
        it { should compile }
        it { should_not contain_package('git') }
        it { should contain_class('apache') \
          .with_package_ensure('absent')
        }
        it { should contain_apache__vhost('kibana3') \
          .with(
            'ensure'  => 'absent',
            'docroot' => '/opt/kibana3/src'
          ) }
        it { should contain_file('/opt/kibana3') \
          .with_ensure('absent')
        }
        it { should contain_file('/opt/kibana3/src/config.js') \
          .with_ensure('absent')
        }
      end

      context 'without webserver' do
        let (:params) {{ :ensure => 'absent', :manage_ws => false }}
        it { should compile }
        it { should contain_package('git') \
          .with_ensure('absent')
        }
        it { should_not contain_class('apache') }
        it { should_not contain_apache__vhost('kibana3') }
        it { should contain_file('/opt/kibana3') \
          .with_ensure('absent')
        }
        it { should contain_file('/opt/kibana3/src/config.js') \
          .with_ensure('absent')
        }
      end

      context 'with non-standard install folder' do
        let (:params) {{ :ensure => 'absent', :k3_install_folder => '/tmp/kibana3' }}
        it { should compile }
        it { should contain_package('git') \
          .with_ensure('absent')
        }
        it { should contain_class('apache') \
          .with_package_ensure('absent')
        }
        it { should contain_apache__vhost('kibana3') \
          .with(
            'ensure'  => 'absent',
            'docroot' => '/tmp/kibana3/src'
          ) }
        it { should contain_file('/tmp/kibana3') \
          .with_ensure('absent')
        }
        it { should contain_file('/tmp/kibana3/src/config.js') \
          .with_ensure('absent')
        }
      end
    end

  end
end
