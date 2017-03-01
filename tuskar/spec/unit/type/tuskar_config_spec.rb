require 'puppet'
require 'puppet/type/tuskar_config'
describe 'Puppet::Type.type(:tuskar_config)' do
  before :each do
    @tuskar_config = Puppet::Type.type(:tuskar_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should require a name' do
    expect {
      Puppet::Type.type(:tuskar_config).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should not expect a name with whitespace' do
    expect {
      Puppet::Type.type(:tuskar_config).new(:name => 'f oo')
    }.to raise_error(Puppet::Error, /Parameter name failed/)
  end

  it 'should fail when there is no section' do
    expect {
      Puppet::Type.type(:tuskar_config).new(:name => 'foo')
    }.to raise_error(Puppet::Error, /Parameter name failed/)
  end

  it 'should not require a value when ensure is absent' do
    Puppet::Type.type(:tuskar_config).new(:name => 'DEFAULT/foo', :ensure => :absent)
  end

  it 'should accept a valid value' do
    @tuskar_config[:value] = 'bar'
    expect(@tuskar_config[:value]).to eq('bar')
  end

  it 'should not accept a value with whitespace' do
    @tuskar_config[:value] = 'b ar'
    expect(@tuskar_config[:value]).to eq('b ar')
  end

  it 'should accept valid ensure values' do
    @tuskar_config[:ensure] = :present
    expect(@tuskar_config[:ensure]).to eq(:present)
    @tuskar_config[:ensure] = :absent
    expect(@tuskar_config[:ensure]).to eq(:absent)
  end

  it 'should not accept invalid ensure values' do
    expect {
      @tuskar_config[:ensure] = :latest
    }.to raise_error(Puppet::Error, /Invalid value/)
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    package = Puppet::Type.type(:package).new(:name => 'tuskar-api')
    catalog.add_resource package, @tuskar_config
    dependency = @tuskar_config.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@tuskar_config)
    expect(dependency[0].source).to eq(package)
  end

end
