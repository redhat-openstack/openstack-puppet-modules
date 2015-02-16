require 'puppet'
require 'puppet/type/remote_database'

describe Puppet::Type.type(:remote_database) do

  before :each do
    @resource = Puppet::Type.type(:remote_database).new(
        :name => 'test', :charset => 'utf8', :collate => 'utf8_blah_ci',
        :db_host => 'localhost', :db_user => 'user', :db_password => 'pass'
    )
  end

  it 'should accept a database name' do
    expect(@resource[:name]).to eq('test')
  end

  it 'should accept a charset' do
    expect(@resource[:charset]).to eq('utf8')
  end

  it 'should accept a collate' do
    expect(@resource[:collate]).to eq('utf8_blah_ci')
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

  it 'should require a name' do
    expect {
      Puppet::Type.type(:remote_database).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

end
