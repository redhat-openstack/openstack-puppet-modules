
require 'spec_helper'

provider_class = Puppet::Type.type(:remote_database).provider(:mysql)

describe provider_class do
  subject { provider_class }

  let (:host) { '--host=localhost' }
  let (:user) { '--user=user' }
  let (:password) { '--password=pass' }

  let (:parsed_databases) { %w(information_schema mydb mysql performance_schema test) }
  let :raw_databases do
    <<-SQL_OUTPUT
information_schema
mydb
mysql
performance_schema
test
    SQL_OUTPUT
  end

  let :resource do
    Puppet::Type.type(:remote_database).new({
      :name => 'test',
      :charset => 'utf8',
      :collate => 'utf8_blah_ci',
      :db_host => 'localhost',
      :db_user => 'user',
      :db_password => 'pass'
    })
  end
  let (:provider) { resource.provider }

  before :each do
    Facter.stubs(:value).with(:kernel).returns('Linux')
    Puppet::Util.stubs(:which).with('mysql').returns('/usr/bin/mysql')
    provider.class.stubs(:mysql).with([host, user, password, '-NBe', 'show databases']).returns(raw_databases)
    provider.class.stubs(:mysql).with([host, user, password, '-NBe', 'create database `test` character set utf8 collate utf8_blah_ci'])
  end


  describe 'self.instances' do
    it 'returns an array of databases' do
      provider.class.stubs(:mysql).with(['-NBe', 'show databases']).returns(raw_databases)
      databases = provider.class.instances.collect {|x| x.name }
      expect(parsed_databases).to match_array(databases)
    end
  end

  describe 'create' do
    it 'makes a database' do
      provider.expects(:mysql).with([host, user, password, '-NBe', "create database `#{resource[:name]}` character set #{resource[:charset]} collate #{resource[:collate]}"])
      expect(provider.create)
    end
  end
end
