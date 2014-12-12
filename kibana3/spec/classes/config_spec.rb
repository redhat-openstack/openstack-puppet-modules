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

    describe "config on #{system}" do
      context 'with defaults' do
        it { should compile }
        it { should contain_file('/opt/kibana3/src/config.js') \
          .with_content(/^\s*elasticsearch: \"http:\/\/\"\+window\.location\.hostname\+\":9200\",$/) \
          .with_content(/^\s*default_route: '\/dashboard\/file\/default\.json',$/) \
          .with_content(/^\s*kibana_index: \"kibana-int\",$/) \
          .with_content(/^\s*panel_names: \[\s*'histogram',\s*'map',\s*'goal',\s*'table',\s*'filtering',\s*'timepicker',\s*'text',\s*'hits',\s*'column',\s*'trends',\s*'bettermap',\s*'query',\s*'terms',\s*'stats',\s*'sparklines',\s*\]$/) \
          .that_notifies('Class[Apache::Service]')
        }
      end

      context 'without webserver' do
        let (:params) {{ :manage_ws => false }}
        it { should compile }
        it { should contain_file('/opt/kibana3/src/config.js') \
          .with_owner('root') \
          .with_content(/^\s*elasticsearch: \"http:\/\/\"\+window\.location\.hostname\+\":9200\",$/) \
          .with_content(/^\s*default_route: '\/dashboard\/file\/default\.json',$/) \
          .with_content(/^\s*kibana_index: \"kibana-int\",$/) \
          .with_content(/^\s*panel_names: \[\s*'histogram',\s*'map',\s*'goal',\s*'table',\s*'filtering',\s*'timepicker',\s*'text',\s*'hits',\s*'column',\s*'trends',\s*'bettermap',\s*'query',\s*'terms',\s*'stats',\s*'sparklines',\s*\]$/)
        }
      end

      context 'with non-standard install folder' do
        let (:params) {{ :k3_install_folder => '/tmp/kibana3' }}
        it { should compile }
        it { should contain_file('/tmp/kibana3/src/config.js') \
          .with_content(/^\s*elasticsearch: \"http:\/\/\"\+window\.location\.hostname\+\":9200\",$/) \
          .with_content(/^\s*default_route: '\/dashboard\/file\/default\.json',$/) \
          .with_content(/^\s*kibana_index: \"kibana-int\",$/) \
          .with_content(/^\s*panel_names: \[\s*'histogram',\s*'map',\s*'goal',\s*'table',\s*'filtering',\s*'timepicker',\s*'text',\s*'hits',\s*'column',\s*'trends',\s*'bettermap',\s*'query',\s*'terms',\s*'stats',\s*'sparklines',\s*\]$/) \
          .that_notifies('Class[Apache::Service]')
        }
      end

      context 'with folder owner' do
        let (:params) {{ :k3_folder_owner => 'foo' }}
        it { should compile }
        it { should contain_file('/opt/kibana3/src/config.js') \
          .with_owner('foo') \
          .with_content(/^\s*elasticsearch: \"http:\/\/\"\+window\.location\.hostname\+\":9200\",$/) \
          .with_content(/^\s*default_route: '\/dashboard\/file\/default\.json',$/) \
          .with_content(/^\s*kibana_index: \"kibana-int\",$/) \
          .with_content(/^\s*panel_names: \[\s*'histogram',\s*'map',\s*'goal',\s*'table',\s*'filtering',\s*'timepicker',\s*'text',\s*'hits',\s*'column',\s*'trends',\s*'bettermap',\s*'query',\s*'terms',\s*'stats',\s*'sparklines',\s*\]$/) \
          .that_notifies('Class[Apache::Service]')
        }
      end

      context 'with non-standard default route' do
        let (:params) {{ :config_default_route => '/dashboard/file/foo.json' }}
        it { should compile }
        it { should contain_file('/opt/kibana3/src/config.js') \
          .with_content(/^\s*elasticsearch: \"http:\/\/\"\+window\.location\.hostname\+\":9200\",$/) \
          .with_content(/^\s*default_route: '\/dashboard\/file\/foo\.json',$/) \
          .with_content(/^\s*kibana_index: \"kibana-int\",$/) \
          .with_content(/^\s*panel_names: \[\s*'histogram',\s*'map',\s*'goal',\s*'table',\s*'filtering',\s*'timepicker',\s*'text',\s*'hits',\s*'column',\s*'trends',\s*'bettermap',\s*'query',\s*'terms',\s*'stats',\s*'sparklines',\s*\]$/) \
          .that_notifies('Class[Apache::Service]')
        }
      end

      context 'with non-standard elasticsearch port' do
        let (:params) {{ :config_es_port => '8081' }}
        it { should compile }
        it { should contain_file('/opt/kibana3/src/config.js') \
          .with_content(/^\s*elasticsearch: \"http:\/\/\"\+window\.location\.hostname\+\":8081\",$/) \
          .with_content(/^\s*default_route: '\/dashboard\/file\/default\.json',$/) \
          .with_content(/^\s*kibana_index: \"kibana-int\",$/) \
          .with_content(/^\s*panel_names: \[\s*'histogram',\s*'map',\s*'goal',\s*'table',\s*'filtering',\s*'timepicker',\s*'text',\s*'hits',\s*'column',\s*'trends',\s*'bettermap',\s*'query',\s*'terms',\s*'stats',\s*'sparklines',\s*\]$/) \
          .that_notifies('Class[Apache::Service]')
        }
      end

      context 'with non-standard elasticsearch protocol' do
        let (:params) {{ :config_es_protocol => 'https' }}
        it { should compile }
        it { should contain_file('/opt/kibana3/src/config.js') \
          .with_content(/^\s*elasticsearch: \"https:\/\/\"\+window\.location\.hostname\+\":9200\",$/) \
          .with_content(/^\s*default_route: '\/dashboard\/file\/default\.json',$/) \
          .with_content(/^\s*kibana_index: \"kibana-int\",$/) \
          .with_content(/^\s*panel_names: \[\s*'histogram',\s*'map',\s*'goal',\s*'table',\s*'filtering',\s*'timepicker',\s*'text',\s*'hits',\s*'column',\s*'trends',\s*'bettermap',\s*'query',\s*'terms',\s*'stats',\s*'sparklines',\s*\]$/) \
          .that_notifies('Class[Apache::Service]')
        }
      end

      context 'with non-standard elasticsearch server' do
        let (:params) {{ :config_es_server => 'localhost' }}
        it { should compile }
        it { should contain_file('/opt/kibana3/src/config.js') \
          .with_content(/^\s*elasticsearch: \"http:\/\/\localhost:9200\",$/) \
          .with_content(/^\s*default_route: '\/dashboard\/file\/default\.json',$/) \
          .with_content(/^\s*kibana_index: \"kibana-int\",$/) \
          .with_content(/^\s*panel_names: \[\s*'histogram',\s*'map',\s*'goal',\s*'table',\s*'filtering',\s*'timepicker',\s*'text',\s*'hits',\s*'column',\s*'trends',\s*'bettermap',\s*'query',\s*'terms',\s*'stats',\s*'sparklines',\s*\]$/) \
          .that_notifies('Class[Apache::Service]')
        }
      end

      context 'with non-standard kibana index' do
        let (:params) {{ :config_kibana_index => 'kibana-index' }}
        it { should compile }
        it { should contain_file('/opt/kibana3/src/config.js') \
          .with_content(/^\s*elasticsearch: \"http:\/\/\"\+window\.location\.hostname\+\":9200\",$/) \
          .with_content(/^\s*default_route: '\/dashboard\/file\/default\.json',$/) \
          .with_content(/^\s*kibana_index: \"kibana-index\",$/) \
          .with_content(/^\s*panel_names: \[\s*'histogram',\s*'map',\s*'goal',\s*'table',\s*'filtering',\s*'timepicker',\s*'text',\s*'hits',\s*'column',\s*'trends',\s*'bettermap',\s*'query',\s*'terms',\s*'stats',\s*'sparklines',\s*\]$/) \
          .that_notifies('Class[Apache::Service]')
        }
      end

      context 'with non-standard panel names' do
        let (:params) {{ :config_panel_names => ['test1','test2'] }}
        it { should compile }
        it { should contain_file('/opt/kibana3/src/config.js') \
          .with_content(/^\s*elasticsearch: \"http:\/\/\"\+window\.location\.hostname\+\":9200\",$/) \
          .with_content(/^\s*default_route: '\/dashboard\/file\/default\.json',$/) \
          .with_content(/^\s*kibana_index: \"kibana-int\",$/) \
          .with_content(/^\s*panel_names: \[\s*'test1',\s*'test2',\s*\]$/) \
          .that_notifies('Class[Apache::Service]')
        }
      end
    end

  end
end
