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

    describe "init on #{system}" do
      context 'with defaults' do
        it { should compile }
        it { should contain_class 'kibana3::params' }
        it { should contain_anchor('kibana3::begin') \
          .that_comes_before('Class[kibana3::install]')
        }
        it { should contain_class('kibana3::install') \
          .that_comes_before('Class[kibana3::config]')
        }
        it { should contain_class('kibana3::config') \
          .that_comes_before('Anchor[kibana3::end]')
        }
        it { should contain_anchor 'kibana3::end'}
        it { should_not contain_class 'kibana3::uninstall' }
      end

      context 'with ensure absent' do
        let (:params) {{ :ensure => 'absent' }}
        it { should compile }
        it { should contain_class 'kibana3::params' }
        it { should_not contain_anchor 'kibana3::begin' }
        it { should_not contain_class 'kibana3::install' }
        it { should_not contain_class 'kibana3::config' }
        it { should_not contain_anchor 'kibana3::end' }
        it { should contain_class 'kibana3::uninstall' }
      end

      context 'with unsupported ensure' do
        let (:params) {{ :ensure => 'foobar' }}
        it do
          expect {
            should compile
          }.to raise_error
        end
      end
    end

  end
end
