require 'puppet'
require 'puppet/type/gnocchi_config'
describe 'Puppet::Type.type(:gnocchi_config)' do
  before :each do
    @gnocchi_config = Puppet::Type.type(:gnocchi_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should require a name' do
    expect {
      Puppet::Type.type(:gnocchi_config).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should not expect a name with whitespace' do
    expect {
      Puppet::Type.type(:gnocchi_config).new(:name => 'f oo')
    }.to raise_error(Puppet::Error, /Parameter name failed/)
  end

  it 'should fail when there is no section' do
    expect {
      Puppet::Type.type(:gnocchi_config).new(:name => 'foo')
    }.to raise_error(Puppet::Error, /Parameter name failed/)
  end

  it 'should not require a value when ensure is absent' do
    Puppet::Type.type(:gnocchi_config).new(:name => 'DEFAULT/foo', :ensure => :absent)
  end

  it 'should accept a valid value' do
    @gnocchi_config[:value] = 'bar'
    expect(@gnocchi_config[:value]).to eq('bar')
  end

  it 'should not accept a value with whitespace' do
    @gnocchi_config[:value] = 'b ar'
    expect(@gnocchi_config[:value]).to eq('b ar')
  end

  it 'should accept valid ensure values' do
    @gnocchi_config[:ensure] = :present
    expect(@gnocchi_config[:ensure]).to eq(:present)
    @gnocchi_config[:ensure] = :absent
    expect(@gnocchi_config[:ensure]).to eq(:absent)
  end

  it 'should not accept invalid ensure values' do
    expect {
      @gnocchi_config[:ensure] = :latest
    }.to raise_error(Puppet::Error, /Invalid value/)
  end
end
