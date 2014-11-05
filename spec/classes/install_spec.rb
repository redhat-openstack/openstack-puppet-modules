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

    describe "install on #{system}" do
      context 'with defaults' do
        it { should compile }
        it { should contain_class('git') }
        it { should contain_class('apache') }
        it { should contain_vcsrepo('/opt/kibana3') \
          .with_revision('a50a913') \
          .that_notifies('Class[Apache::Service]') \
          .that_comes_before('Apache::Vhost[kibana3]') }
        it { should contain_apache__vhost('kibana3') \
          .with(
            'port'    => '80',
            'docroot' => '/opt/kibana3/src'
          ) }
      end

      context 'without git' do
        let (:params) {{ :manage_git => false }}
        it { should compile }
        it { should_not contain_class('git') }
        it { should contain_class('apache') }
        it { should contain_vcsrepo('/opt/kibana3') \
          .with_revision('a50a913') \
          .that_notifies('Class[Apache::Service]') \
          .that_comes_before('Apache::Vhost[kibana3]') }
        it { should contain_apache__vhost('kibana3') \
          .with(
            'port'    => '80',
            'docroot' => '/opt/kibana3/src'
          ) }
      end

      context 'without webserver' do
        let (:params) {{ :manage_ws => false }}
        it { should compile }
        it { should contain_class('git') }
        it { should_not contain_class('apache') }
        it { should contain_vcsrepo('/opt/kibana3') \
          .with(
            'revision' => 'a50a913',
            'owner'    => 'root'
          ) }
        it { should_not contain_apache__vhost('kibana3') }
      end

      context 'with folder owner' do
        let (:params) {{ :k3_folder_owner => 'foo' }}
        it { should compile }
        it { should contain_class('git') }
        it { should contain_class('apache') }
        it { should contain_vcsrepo('/opt/kibana3') \
          .with(
            'revision' => 'a50a913',
            'owner'    => 'foo'
          ) \
          .that_notifies('Class[Apache::Service]') \
          .that_comes_before('Apache::Vhost[kibana3]') }
        it { should contain_apache__vhost('kibana3') \
          .with(
            'port'          => '80',
            'docroot'       => '/opt/kibana3/src',
            'docroot_owner' => 'foo'
          ) }
      end

      context 'with non-standard install folder' do
        let (:params) {{ :k3_install_folder => '/tmp/kibana3' }}
        it { should compile }
        it { should contain_class('git') }
        it { should contain_class('apache') }
        it { should contain_vcsrepo('/tmp/kibana3') \
          .with_revision('a50a913') \
          .that_notifies('Class[Apache::Service]') \
          .that_comes_before('Apache::Vhost[kibana3]') }
        it { should contain_apache__vhost('kibana3') \
          .with(
            'port'    => '80',
            'docroot' => '/tmp/kibana3/src'
          ) }
      end

      context 'with non-standard release' do
        let (:params) {{ :k3_release => '3a485aa' }}
        it { should compile }
        it { should contain_class('git') }
        it { should contain_class('apache') }
        it { should contain_vcsrepo('/opt/kibana3') \
          .with_revision('3a485aa') \
          .that_notifies('Class[Apache::Service]') \
          .that_comes_before('Apache::Vhost[kibana3]') }
        it { should contain_apache__vhost('kibana3') \
          .with(
            'port'    => '80',
            'docroot' => '/opt/kibana3/src'
          ) }
      end

      context 'with non-standard port' do
        let (:params) {{ :ws_port => '8080' }}
        it { should compile }
        it { should contain_class('git') }
        it { should contain_class('apache') }
        it { should contain_vcsrepo('/opt/kibana3') \
          .with_revision('a50a913') \
          .that_notifies('Class[Apache::Service]') \
          .that_comes_before('Apache::Vhost[kibana3]') }
        it { should contain_apache__vhost('kibana3') \
          .with(
            'port'    => '8080',
            'docroot' => '/opt/kibana3/src'
          ) }
      end

      context 'with manage_git_repository set to false' do
        let (:params) {{ :manage_git_repository => false }}
        it { should_not contain_vcsrepo('/opt/kibana3') }
      end
    end

  end
end
