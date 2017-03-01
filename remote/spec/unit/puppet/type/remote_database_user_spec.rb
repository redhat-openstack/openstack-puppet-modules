require 'puppet'
require 'puppet/type/remote_database_user'

describe Puppet::Type.type(:remote_database_user) do

  it 'should fail with a long user name' do
    expect {
      Puppet::Type.type(:remote_database_user).new(
        :name => '12345678901234567@localhost', :password_hash => 'pass'
      )
    }.to raise_error /MySQL usernames are limited to a maximum of 16 characters/
  end

  it 'should require a name' do
    expect {
      Puppet::Type.type(:remote_database_user).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  context 'using foo@localhost' do
    before :each do
      @resource = Puppet::Type.type(:remote_database_user).new(
        :name => 'foo@localhost', :password_hash => 'pass',
        :db_host => 'localhost', :db_user => 'user', :db_password => 'pass2'
      )
    end

    it 'should accept a user name' do
      expect(@resource[:name]).to eq('foo@localhost')
    end

    it 'should accept a password' do
      expect(@resource[:password_hash]).to eq('pass')
    end

    it 'should accept a database host' do
      expect(@resource[:db_host]).to eq('localhost')
    end

    it 'should accept a database user' do
      expect(@resource[:db_user]).to eq('user')
    end

    it 'should accept a database password' do
      expect(@resource[:db_password]).to eq('pass2')
    end
  end

  context 'using foo@LocalHost' do
    before :each do
      @resource = Puppet::Type.type(:remote_database_user).new(
        :name => 'foo@LocalHost', :password_hash => 'pass'
      )
    end

    it 'should lowercase the user name' do
      expect(@resource[:name]).to eq('foo@localhost')
    end
  end

  context 'using allo_wed$char@localhost' do
    before :each do
      @resource = Puppet::Type.type(:remote_database_user).new(
        :name => 'allo_wed$char@localhost', :password_hash => 'pass'
      )
    end

    it 'should accept a user name' do
      expect(@resource[:name]).to eq('allo_wed$char@localhost')
    end
  end

  context 'ensure the default \'debian-sys-main\'@localhost user can be parsed' do
    before :each do
      @resource = Puppet::Type.type(:remote_database_user).new(
        :name => '\'debian-sys-maint\'@localhost', :password_hash => 'pass'
      )
    end

    it 'should accept a user name' do
      expect(@resource[:name]).to eq('\'debian-sys-maint\'@localhost')
    end
  end

  context 'using a quoted 16 char username' do
    before :each do
      @resource = Puppet::Type.type(:remote_database_user).new(
        :name => '"debian-sys-maint"@localhost', :password_hash => 'pass'
      )
    end

    it 'should accept a user name' do
      expect(@resource[:name]).to eq('"debian-sys-maint"@localhost')
    end
  end

  context 'using a quoted username that is too long ' do
    it 'should fail with a size error' do
      expect {
        Puppet::Type.type(:remote_database_user).new(:name => '"debian-sys-maint2"@localhost', :password_hash => 'pass')
      }.to raise_error /MySQL usernames are limited to a maximum of 16 characters/
    end
  end

  context 'using `speci!al#`@localhost' do
    before :each do
      @resource = Puppet::Type.type(:remote_database_user).new(
        :name => '`speci!al#`@localhost', :password_hash => 'pass'
      )
    end

    it 'should accept a quoted user name with special chatracters' do
      expect(@resource[:name]).to eq('`speci!al#`@localhost')
    end
  end

  context 'using "misquoted@localhost' do
    it 'should fail with a misquoted username is used' do
      expect {
        Puppet::Type.type(:remote_database_user).new(:name => '"misquoted@localhost', :password_hash => 'pass')
      }.to raise_error /Invalid database user "misquoted@localhost/
    end
  end
end
