require 'spec_helper'

describe 'tuskar::db::postgresql' do

  let :req_params do
    { :password => 'pw' }
  end

  let :pre_condition do
    'include postgresql::server'
  end

  context 'on a RedHat osfamily' do
    let :facts do
      {
        :osfamily                 => 'RedHat',
        :operatingsystemrelease   => '7.0',
        :concat_basedir => '/var/lib/puppet/concat'
      }
    end

    context 'with only required parameters' do
      let :params do
        req_params
      end

      it { should contain_postgresql__server__db('tuskar').with(
        :user     => 'tuskar',
        :password => 'md532cc9d9d42efb508bc9d6267d873d63d'
      )}
    end

  end

  context 'on a Debian osfamily' do
    let :facts do
      {
        :operatingsystemrelease => '7.8',
        :operatingsystem        => 'Debian',
        :osfamily               => 'Debian',
        :concat_basedir => '/var/lib/puppet/concat'
      }
    end

    context 'with only required parameters' do
      let :params do
        req_params
      end

      it { should contain_postgresql__server__db('tuskar').with(
        :user     => 'tuskar',
        :password => 'md532cc9d9d42efb508bc9d6267d873d63d'
      )}
    end

  end

end
