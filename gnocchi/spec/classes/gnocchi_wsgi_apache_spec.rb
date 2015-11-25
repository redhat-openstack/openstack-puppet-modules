require 'spec_helper'

describe 'gnocchi::wsgi::apache' do

  let :global_facts do
    {
      :processorcount => 42,
      :concat_basedir => '/var/lib/puppet/concat',
      :fqdn           => 'some.host.tld'
    }
  end

  shared_examples_for 'apache serving gnocchi with mod_wsgi' do
    it { is_expected.to contain_service('httpd').with_name(platform_parameters[:httpd_service_name]) }
    it { is_expected.to contain_class('gnocchi::params') }
    it { is_expected.to contain_class('apache') }
    it { is_expected.to contain_class('apache::mod::wsgi') }

    describe 'with default parameters' do

      it { is_expected.to contain_file("#{platform_parameters[:wsgi_script_path]}").with(
        'ensure'  => 'directory',
        'owner'   => 'gnocchi',
        'group'   => 'gnocchi',
        'require' => 'Package[httpd]'
      )}


      it { is_expected.to contain_file('gnocchi_wsgi').with(
        'ensure'  => 'file',
        'path'    => "#{platform_parameters[:wsgi_script_path]}/app",
        'source'  => platform_parameters[:wsgi_script_source],
        'owner'   => 'gnocchi',
        'group'   => 'gnocchi',
        'mode'    => '0644'
      )}
      it { is_expected.to contain_file('gnocchi_wsgi').that_requires("File[#{platform_parameters[:wsgi_script_path]}]") }

      it { is_expected.to contain_apache__vhost('gnocchi_wsgi').with(
        'servername'                  => 'some.host.tld',
        'ip'                          => nil,
        'port'                        => '8041',
        'docroot'                     => "#{platform_parameters[:wsgi_script_path]}",
        'docroot_owner'               => 'gnocchi',
        'docroot_group'               => 'gnocchi',
        'ssl'                         => 'true',
        'wsgi_daemon_process'         => 'gnocchi',
        'wsgi_process_group'          => 'gnocchi',
        'wsgi_script_aliases'         => { '/' => "#{platform_parameters[:wsgi_script_path]}/app" },
        'require'                     => 'File[gnocchi_wsgi]'
      )}
      it { is_expected.to contain_file("#{platform_parameters[:httpd_ports_file]}") }
    end

    describe 'when overriding parameters using different ports' do
      let :params do
        {
          :servername  => 'dummy.host',
          :bind_host   => '10.42.51.1',
          :port        => 12345,
          :ssl         => false,
          :workers     => 37,
        }
      end

      it { is_expected.to contain_apache__vhost('gnocchi_wsgi').with(
        'servername'                  => 'dummy.host',
        'ip'                          => '10.42.51.1',
        'port'                        => '12345',
        'docroot'                     => "#{platform_parameters[:wsgi_script_path]}",
        'docroot_owner'               => 'gnocchi',
        'docroot_group'               => 'gnocchi',
        'ssl'                         => 'false',
        'wsgi_daemon_process'         => 'gnocchi',
        'wsgi_process_group'          => 'gnocchi',
        'wsgi_script_aliases'         => { '/' => "#{platform_parameters[:wsgi_script_path]}/app" },
        'require'                     => 'File[gnocchi_wsgi]'
      )}

      it { is_expected.to contain_file("#{platform_parameters[:httpd_ports_file]}") }
    end
  end

  context 'on RedHat platforms' do
    let :facts do
      global_facts.merge({
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '7.0'
      })
    end

    let :platform_parameters do
      {
        :httpd_service_name => 'httpd',
        :httpd_ports_file   => '/etc/httpd/conf/ports.conf',
        :wsgi_script_path   => '/var/www/cgi-bin/gnocchi',
        :wsgi_script_source => '/usr/lib/python2.7/site-packages/gnocchi/rest/app.wsgi'
      }
    end

    it_configures 'apache serving gnocchi with mod_wsgi'
  end

  context 'on Debian platforms' do
    let :facts do
      global_facts.merge({
        :osfamily               => 'Debian',
        :operatingsystem        => 'Debian',
        :operatingsystemrelease => '7.0'
      })
    end

    let :platform_parameters do
      {
        :httpd_service_name => 'apache2',
        :httpd_ports_file   => '/etc/apache2/ports.conf',
        :wsgi_script_path   => '/usr/lib/cgi-bin/gnocchi',
        :wsgi_script_source => '/usr/share/gnocchi-common/app.wsgi'
      }
    end

    it_configures 'apache serving gnocchi with mod_wsgi'
  end
end
