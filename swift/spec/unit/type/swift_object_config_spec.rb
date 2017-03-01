require 'puppet'
require 'puppet/type/swift_object_config'

describe 'Puppet::Type.type(:swift_object_config)' do
  before :each do
    @swift_object_config = Puppet::Type.type(:swift_object_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    package = Puppet::Type.type(:package).new(:name => 'swift-object')
    catalog.add_resource package, @swift_object_config
    dependency = @swift_object_config.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@swift_object_config)
    expect(dependency[0].source).to eq(package)
  end

end
