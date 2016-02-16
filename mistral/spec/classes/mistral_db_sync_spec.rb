require 'spec_helper'

describe 'mistral::db::sync' do

  shared_examples_for 'mistral-db-sync' do

    it 'runs mistral-db-manage upgrade head' do

      is_expected.to contain_exec('mistral-db-sync').with(
        :command     => 'mistral-db-manage --config-file=/etc/mistral/mistral.conf upgrade head',
        :path        => '/usr/bin',
        :user        => 'mistral',
        :refreshonly => 'true',
        :logoutput   => 'on_failure'
      )

      is_expected.to contain_exec('mistral-db-populate').with(
        :command     => 'mistral-db-manage --config-file=/etc/mistral/mistral.conf populate',
        :path        => '/usr/bin',
        :user        => 'mistral',
        :refreshonly => 'true',
        :logoutput   => 'on_failure'
      )

    end

  end

  context 'on a RedHat osfamily' do
    let :facts do
      {
        :osfamily                 => 'RedHat',
        :operatingsystemrelease   => '7.0',
        :concat_basedir => '/var/lib/puppet/concat'
      }
    end

    it_configures 'mistral-db-sync'
  end

  context 'on a Debian osfamily' do
    let :facts do
      {
        :operatingsystemrelease => '8.0',
        :osfamily               => 'Debian',
        :concat_basedir => '/var/lib/puppet/concat'
      }
    end

    it_configures 'mistral-db-sync'
  end

end
