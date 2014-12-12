require 'spec_helper'

describe 'cloud::install::puppetmaster' do

  shared_examples_for 'puppetmaster' do

    let :params do
      { :puppetconf_path     => '/etc/puppet/puppet.conf',
        :main_configuration  => {},
        :agent_configuration => {
          'certname' => { 'setting' => 'certname', 'value' => 'foo.bar' }
        },
        :master_configuration => {
          'timeout'  => { 'setting' => 'timeout', 'value' => '0' }
        }}
    end

    it 'install puppetmaster package' do
      is_expected.to contain_package(platform_params[:puppetmaster_package_name]).with({
        :ensure => 'present',
      })
    end

    it 'ensure puppetmaster is stopped' do
      is_exptected.to contain_server(platform_params[:puppetmaster_service_name]).with({
        :ensure     => 'stopped',
        :hasstatus  => true,
        :hasrestart => true,
      })
    end

    it 'generate certificate if necessary' do
      is_expected.to contain_exec('puppet cert generate node.example.com')
    end

    it 'install hiera' do
      is_expected.to contain_class('hiera')
    end

    it 'configure the puppetdb settings of puppetmaster' do
      is_exptected.to contain_class('puppetdb::master::config')
    end

    it 'configure the puppet master configuration file' do
      is_expected.to contain_init_setting('certname').with(
        :setting => 'certname',
        :value   => 'foo.bar',
        :section => 'agent',
        :path    => '/etc/puppet/puppet.conf',
      )
      is_expected.to contain_init_setting('timeout').with(
        :setting => 'timeout',
        :value   => '0',
        :section => 'master',
        :path    => '/etc/puppet/puppet.conf',
      )
    end

    it 'configure the autosign.conf' do
      is_expected.to contain_file('/etc/puppet/autosign/conf').with({
        :ensure => 'present',
        :owner  => 'puppet',
        :group  => 'puppet',
        :conent => 'template(\'cloud/installserver/autosign.conf.erb\')',
      })
    end

  end


  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian',
        :fqdn     => 'node.example.com'
      }
    end

    let :platform_params do
      { :puppetmaster_package_name => 'puppet-server',
        :puppetmaster_service_name => 'puppetmaster',
      }
    end

    it_configures 'puppetmaster'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat',
        :fqdn     => 'node.example.com'
      }
    end

    let :platform_params do
      { :puppetmaster_package_name => 'puppetmaster',
        :puppetmaster_service_name => 'puppetmaster',
      }
    end

    it_configures 'puppetmaster'

    context 'on Maj Release 7' do
      facts.merge!(:operatingsystemmajrelease => '7')

      it 'ensure package mod_passenger is not installed' do
        is_expected.to contain_package('mod_passenger').with({
          :ensure => 'absent',
        })
      end
    end
  end
end
