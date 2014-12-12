require 'spec_helper'

describe 'cloud::install::puppetdb_server' do

  shared_examples_for 'puppetdb' do

    it 'install puppetdb' do
      is_exptected.to contain_class('puppetdb::server')
    end

  end


  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'puppetdb'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end
    it_configures 'puppetdb'
  end
end
