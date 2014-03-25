require 'spec_helper'

describe 'kibana3', :type => :class do
  let :facts do
    {
      :concat_basedir         => '/dne',
      :osfamily               => 'Debian',
      :operatingsystemrelease => '12.04',
    }
  end

  context 'with defaults' do
    it { should compile }
    it { should create_class('kibana3::install') }
    it { should create_class('kibana3::config') }

    it { should contain_class('git') }

    it { should contain_class('apache') }
    it { should contain_file('25-kibana3.conf') }
    it {
      should contain_file('15-default.conf') \
        .with_ensure('absent')
    }
    it {
      should contain_file('/opt/kibana3/src') \
        .with_owner('www-data')
    }

    it { should have_vcsrepo_resource_count(1) }

    it {
      should contain_file('/opt/kibana3/src/config.js') \
        .with_owner('www-data')
    }
  end

  context 'disable managed git' do
    let (:params) {{ :manage_git => false }}
    it { should_not contain_class('git') }
  end

  context 'disable managed webserver' do
    let (:params) {{ :manage_ws => false }}
    it { should_not contain_class('apache') }
    it { should_not contain_file('25-kibana3.conf') }
    it {
      should contain_file('/opt/kibana3/src/config.js') \
        .with_owner('root')
    }
  end

  context 'nonstandard web server port' do
    let (:params) {{ :ws_port => '8080' }}
    it {
      should contain_file('25-kibana3.conf') \
        .with_content(/^<VirtualHost \*:8080>$/)
    }
  end

  context 'nonstandard install folder' do
    let (:params) {{ :k3_install_folder => '/tmp/kibana3' }}
    it { should contain_file('/tmp/kibana3/src') }
    it { should contain_file('/tmp/kibana3/src/config.js') }
  end

  context 'nonstandard folder owner' do
    let (:params) {{ :k3_folder_owner => 'foobar' }}

    it {
      should contain_file('/opt/kibana3/src') \
        .with_owner('foobar')
    }

    it {
      should contain_file('/opt/kibana3/src/config.js') \
        .with_owner('foobar')
    }
  end

  context 'nonstandard config options' do
    let :params do
      {
        :config_default_route => '/dashboard/file/test.json',
        :config_es_port       => '80',
        :config_es_protocol   => 'https',
        :config_es_server     => '127.0.0.1',
        :config_kibana_index  => 'kibana3-int',
        :config_panel_names   => ['test1','test2'],
      }
    end

    it {
      should contain_file('/opt/kibana3/src/config.js') \
        .with_content(/^\s*elasticsearch: \"https:\/\/127\.0\.0\.1:80\",$/)
    }
    it {
      should contain_file('/opt/kibana3/src/config.js') \
        .with_content(/^\s*default_route: '\/dashboard\/file\/test\.json',$/)
    }
    it {
      should contain_file('/opt/kibana3/src/config.js') \
        .with_content(/^\s*kibana_index: "kibana3-int",$/)
    }
    it {
      should contain_file('/opt/kibana3/src/config.js') \
        .with_content(/^\s*panel_names: \[\s*'test1',\s*'test2',\s*\]$/)
    }
  end
end
