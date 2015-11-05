require 'spec_helper'

describe 'zookeeper::service' do
  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      ['RedHat', 'CentOS', 'Amazon', 'Fedora'].each do |operatingsystem|
        let(:facts) {{
          :osfamily        => osfamily,
          :operatingsystem => operatingsystem,
        }}

        describe "zookeeper service with default settings on #{osfamily}" do
          let(:params) {{ }}

          it { should contain_class('zookeeper::service') }

          it { should contain_supervisor__service('zookeeper').with({
            'ensure'      => 'present',
            'enable'      => true,
            'command'     => '/usr/bin/zookeeper-server start-foreground',
            'directory'   => '/',
            'user'        => 'zookeeper',
            'group'       => 'zookeeper',
            'autorestart' => true,
            'startsecs'   => 10,
            'retries'     => 999,
            'stopsignal'  => 'INT',
            'stopasgroup' => true,
            'stdout_logfile_maxsize' => '20MB',
            'stdout_logfile_keep'    => 5,
            'stderr_logfile_maxsize' => '20MB',
            'stderr_logfile_keep'    => 10,
            'require'     => [ 'Class[Zookeeper::Config]', 'Class[Supervisor]' ],
          })}

          it { should contain_service('zookeeper-server').with({
            'ensure' => 'stopped',
            'enable' => false,
          })}

          it { should contain_exec('restart-zookeeper').with({
            'command'     => 'supervisorctl restart zookeeper',
            'path'        => ['/usr/bin', '/usr/sbin', '/sbin', '/bin'],
            'user'        => 'root',
            'refreshonly' => true,
            'subscribe'   => 'File[/etc/zookeeper/conf/zoo.cfg]',
            'onlyif'      => 'which supervisorctl &>/dev/null',
            'require'     => [ 'Class[Zookeeper::Config]', 'Class[Supervisor]' ],
          })}
        end

      end
    end
  end
end
