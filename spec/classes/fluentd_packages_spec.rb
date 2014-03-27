require 'spec_helper'

describe 'fluentd::packages', :type => :class do
  let (:params) {{:package_name => 'td-agent', :package_ensure => 'installed'}}
  context "On a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '7',
        :concat_basedir         => '/tmp',
        :lsbdistid              => 'Debian',
      }
    end

    context "with install_repo=>true" do
      let(:params) { {:install_repo => true} }
      it do
        should contain_apt__source("treasure-data").with(
          'location'  => 'http://packages.treasure-data.com/debian',
        )
      end
    end
    it { should contain_package("libxslt1.1").with(
      'ensure'  => 'installed',
      )
    }
    it { should contain_package("libyaml-0-2").with(
      'ensure'  => 'installed',
      )
    }
    it { should contain_package("td-agent").with(
      'ensure'  => 'installed',
      )
    }
  end
  context "On a Redhat OS" do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6.5',
        :concat_basedir         => '/tmp',
        :lsbdistid              => 'CentOS',
      }
    end
    it { should contain_class('fluentd::packages')}
    context "with install_repo=>true" do
      let(:params) { {:install_repo => true} }
      it do
        should contain_file('/etc/yum.repos.d/td.repo').with_content(/^name=TreasureData$/)
      end
    end
    it { should contain_package("td-agent").with(
      'ensure'  => 'installed',
      )
    }
  end
end

