require 'puppet'
require 'puppet/type/remote_database_grant'

describe Puppet::Type.type(:remote_database_grant) do

  it 'should require a name' do
    expect {
      Puppet::Type.type(:remote_database_grant).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  context 'using foo@localhost/database' do
    before :each do
      @resource = Puppet::Type.type(:remote_database_grant).new(
          :name => 'foo@localhost/database', :privileges => ['ALL', 'PROXY'],
          :db_host => 'localhost', :db_user => 'user', :db_password => 'pass'
      )
    end

    it 'should accept a grant name' do
      expect(@resource[:name]).to eq('foo@localhost/database')
    end

    it 'should accept a privileges' do
      expect(@resource[:privileges]).to eq(['ALL', 'PROXY'])
    end

    it 'should accept a database host' do
      expect(@resource[:db_host]).to eq('localhost')
    end

    it 'should accept a database user' do
      expect(@resource[:db_user]).to eq('user')
    end

    it 'should accept a database password' do
      expect(@resource[:db_password]).to eq('pass')
    end
  end

  context 'using foo@localhost' do
    before :each do
      @resource = Puppet::Type.type(:remote_database_grant).new(
          :name => 'foo@localhost', :privileges => ['ALL', 'PROXY'],
          :db_host => 'localhost', :db_user => 'user', :db_password => 'pass'
      )
    end

    it 'should accept a grant name' do
      expect(@resource[:name]).to eq('foo@localhost')
    end
  end



end
