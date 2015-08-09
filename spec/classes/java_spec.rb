require 'spec_helper'
describe 'cassandra::java' do
  context 'On a RedHat OS with defaults for all parameters' do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    it { should contain_class('cassandra::java') }
    it { should contain_package('java-1.8.0-openjdk-headless') }
    it { should contain_package('jna') }
  end

  context 'On a Debian OS with defaults for all parameters' do
    let :facts do
      {
        :osfamily => 'Debian'
      }
    end

    it { should contain_class('cassandra::java') }
    it { should contain_package('openjdk-7-jre-headless') }
    it { should contain_package('libjna-java') }
  end

  context 'With package names set to foobar' do
    let :params do
      {
        :package_name       => 'foobar-java',
        :ensure             => '42',
        :jna_package_name   => 'foobar-jna',
        :jna_ensure         => 'latest',
      }
    end

    it {
      should contain_package('foobar-java').with({
        :ensure => 42,
      })
    }

    it {
      should contain_package('foobar-jna').with({
        :ensure => 'latest',
      })
    }
  end
end
