require 'spec_helper'

describe 'keystone::wsgi::apache' do

  let :global_facts do
    {
      :processorcount => 42,
      :concat_basedir => '/var/lib/puppet/concat',
      :fqdn           => 'some.host.tld'
    }
  end

  let :pre_condition do
    [
     'class { keystone: admin_token => "dummy", service_name => "httpd", enable_ssl => true }'
    ]
  end

  #   concat::fragment { "${name}-wsgi":
  # $filename = regsubst($name, ' ', '_', 'G')
  #     target  => "${priority_real}-${filename}.conf",
  # $safe_name        = regsubst($name, '[/:\n]', '_', 'GM')
  # $safe_target_name = regsubst($target, '[/:\n]', '_', 'GM')
  # $concatdir        = $concat::setup::concatdir
  # $fragdir          = "${concatdir}/${safe_target_name}"
  # file { "${fragdir}/fragments/${order}_${safe_name}":
  def get_concat_name(base_name)
#    pp subject.resources
    priority = 10
    order = 250
    base_dir = facts[:concat_basedir]
    safe_name = base_name.gsub(/[\/:\n]/m, '_') + '-wsgi'
    target = "#{priority}-#{base_name}.conf"
    safe_target_name = target.gsub(/[\/:\n]/m, '_')
    frag_dir = "#{base_dir}/#{safe_target_name}"
    full_name = "#{frag_dir}/fragments/#{order}_#{safe_name}"
    return full_name
  end

  shared_examples_for 'apache serving keystone with mod_wsgi' do
    it { should contain_service('httpd').with_name(platform_parameters[:httpd_service_name]) }
    it { should contain_class('keystone::params') }
    it { should contain_class('apache') }
    it { should contain_class('apache::mod::wsgi') }
    it { should contain_class('keystone::db::sync') }

    describe 'with default parameters' do

      it { should contain_file("#{platform_parameters[:wsgi_script_path]}").with(
        'ensure'  => 'directory',
        'owner'   => 'keystone',
        'group'   => 'keystone',
        'require' => 'Package[httpd]'
      )}

      it { should contain_file('keystone_wsgi_admin').with(
        'ensure'  => 'file',
        'path'    => "#{platform_parameters[:wsgi_script_path]}/admin",
        'source'  => platform_parameters[:wsgi_script_source],
        'owner'   => 'keystone',
        'group'   => 'keystone',
        'mode'    => '0644',
        'require' => ["File[#{platform_parameters[:wsgi_script_path]}]", "Package[keystone]"]
      )}

      it { should contain_file('keystone_wsgi_main').with(
        'ensure'  => 'file',
        'path'    => "#{platform_parameters[:wsgi_script_path]}/main",
        'source'  => platform_parameters[:wsgi_script_source],
        'owner'   => 'keystone',
        'group'   => 'keystone',
        'mode'    => '0644',
        'require' => ["File[#{platform_parameters[:wsgi_script_path]}]", "Package[keystone]"]
      )}

      it { should contain_apache__vhost('keystone_wsgi_admin').with(
        'servername'                  => 'some.host.tld',
        'ip'                          => nil,
        'port'                        => '35357',
        'docroot'                     => "#{platform_parameters[:wsgi_script_path]}",
        'docroot_owner'               => 'keystone',
        'docroot_group'               => 'keystone',
        'ssl'                         => 'true',
        'wsgi_daemon_process'         => 'keystone_admin',
        'wsgi_process_group'          => 'keystone_admin',
        'wsgi_script_aliases'         => { '/' => "#{platform_parameters[:wsgi_script_path]}/admin" },
        'require'                     => 'File[keystone_wsgi_admin]'
      )}

      it { should contain_apache__vhost('keystone_wsgi_main').with(
        'servername'                  => 'some.host.tld',
        'ip'                          => nil,
        'port'                        => '5000',
        'docroot'                     => "#{platform_parameters[:wsgi_script_path]}",
        'docroot_owner'               => 'keystone',
        'docroot_group'               => 'keystone',
        'ssl'                         => 'true',
        'wsgi_daemon_process'         => 'keystone_main',
        'wsgi_process_group'          => 'keystone_main',
        'wsgi_script_aliases'         => { '/' => "#{platform_parameters[:wsgi_script_path]}/main" },
        'require'                     => 'File[keystone_wsgi_main]'
      )}
      it { should contain_file(get_concat_name('keystone_wsgi_main')).with_content(
          /^  WSGIDaemonProcess keystone_main group=keystone processes=1 threads=#{facts[:processorcount]} user=keystone$/
      )}
      it { should contain_file(get_concat_name('keystone_wsgi_admin')).with_content(
          /^  WSGIDaemonProcess keystone_admin group=keystone processes=1 threads=#{facts[:processorcount]} user=keystone$/
      )}
      it { should contain_file("#{platform_parameters[:httpd_ports_file]}") }
    end

    describe 'when overriding parameters using different ports' do
      let :params do
        {
          :servername  => 'dummy.host',
          :bind_host   => '10.42.51.1',
          :public_port => 12345,
          :admin_port  => 4142,
          :ssl         => false,
          :workers     => 37,
        }
      end

      it { should contain_apache__vhost('keystone_wsgi_admin').with(
        'servername'                  => 'dummy.host',
        'ip'                          => '10.42.51.1',
        'port'                        => '4142',
        'docroot'                     => "#{platform_parameters[:wsgi_script_path]}",
        'docroot_owner'               => 'keystone',
        'docroot_group'               => 'keystone',
        'ssl'                         => 'false',
        'wsgi_daemon_process'         => 'keystone_admin',
        'wsgi_process_group'          => 'keystone_admin',
        'wsgi_script_aliases'         => { '/' => "#{platform_parameters[:wsgi_script_path]}/admin" },
        'require'                     => 'File[keystone_wsgi_admin]'
      )}

      it { should contain_apache__vhost('keystone_wsgi_main').with(
        'servername'                  => 'dummy.host',
        'ip'                          => '10.42.51.1',
        'port'                        => '12345',
        'docroot'                     => "#{platform_parameters[:wsgi_script_path]}",
        'docroot_owner'               => 'keystone',
        'docroot_group'               => 'keystone',
        'ssl'                         => 'false',
        'wsgi_daemon_process'         => 'keystone_main',
        'wsgi_process_group'          => 'keystone_main',
        'wsgi_script_aliases'         => { '/' => "#{platform_parameters[:wsgi_script_path]}/main" },
        'require'                     => 'File[keystone_wsgi_main]'
      )}
      it { should contain_file(get_concat_name('keystone_wsgi_main')).with_content(
          /^  WSGIDaemonProcess keystone_main group=keystone processes=#{params[:workers]} threads=#{facts[:processorcount]} user=keystone$/
      )}
      it { should contain_file(get_concat_name('keystone_wsgi_admin')).with_content(
          /^  WSGIDaemonProcess keystone_admin group=keystone processes=#{params[:workers]} threads=#{facts[:processorcount]} user=keystone$/
      )}
      it { should contain_file("#{platform_parameters[:httpd_ports_file]}") }
    end

    describe 'when overriding parameters using same port' do
      let :params do
        {
          :servername  => 'dummy.host',
          :public_port => 4242,
          :admin_port  => 4242,
          :public_path => '/main/endpoint/',
          :admin_path  => '/admin/endpoint/',
          :ssl         => true,
          :workers     => 37,
        }
      end

      it { should_not contain_apache__vhost('keystone_wsgi_admin') }

      it { should contain_apache__vhost('keystone_wsgi_main').with(
        'servername'                  => 'dummy.host',
        'ip'                          => nil,
        'port'                        => '4242',
        'docroot'                     => "#{platform_parameters[:wsgi_script_path]}",
        'docroot_owner'               => 'keystone',
        'docroot_group'               => 'keystone',
        'ssl'                         => 'true',
        'wsgi_daemon_process'         => 'keystone_main',
        'wsgi_process_group'          => 'keystone_main',
        'wsgi_script_aliases'         => {
        '/main/endpoint'  => "#{platform_parameters[:wsgi_script_path]}/main",
        '/admin/endpoint' => "#{platform_parameters[:wsgi_script_path]}/admin"
        },
        'require'                     => 'File[keystone_wsgi_main]'
      )}
      it { should contain_file(get_concat_name('keystone_wsgi_main')).with_content(
          /^  WSGIDaemonProcess keystone_main group=keystone processes=#{params[:workers]} threads=#{facts[:processorcount]} user=keystone$/
      )}
      it do
        expect_file = get_concat_name('keystone_wsgi_admin')
        expect {
          should contain_file(expect_file)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected that the catalogue would contain File\[#{expect_file}\]/)
      end
    end

    describe 'when overriding parameters using same port and same path' do
      let :params do
        {
          :servername  => 'dummy.host',
          :public_port => 4242,
          :admin_port  => 4242,
          :public_path => '/endpoint/',
          :admin_path  => '/endpoint/',
          :ssl         => true,
          :workers     => 37,
        }
      end

      it_raises 'a Puppet::Error', /When using the same port for public & private endpoints, public_path and admin_path should be different\./
    end
  end

  context 'on RedHat platforms' do
    let :facts do
      global_facts.merge({
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6.0'
      })
    end

    let :platform_parameters do
      {
        :httpd_service_name => 'httpd',
        :httpd_ports_file   => '/etc/httpd/conf/ports.conf',
        :wsgi_script_path   => '/var/www/cgi-bin/keystone',
        :wsgi_script_source => '/usr/share/keystone/keystone.wsgi'
      }
    end

    it_configures 'apache serving keystone with mod_wsgi'
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
        :wsgi_script_path   => '/usr/lib/cgi-bin/keystone',
        :wsgi_script_source => '/usr/share/keystone/wsgi.py'
      }
    end

    it_configures 'apache serving keystone with mod_wsgi'
  end
end
