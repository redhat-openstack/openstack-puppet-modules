require 'puppet'
require 'puppet/type/manila_config'

describe 'Puppet::Type.type(:manila_config)' do
  before :each do
    @manila_config = Puppet::Type.type(:manila_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    package = Puppet::Type.type(:package).new(:name => 'manila')
    catalog.add_resource package, @manila_config
    dependency = @manila_config.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@manila_config)
    expect(dependency[0].source).to eq(package)
  end

end
