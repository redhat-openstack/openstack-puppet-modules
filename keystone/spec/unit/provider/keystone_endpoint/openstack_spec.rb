require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_endpoint/openstack'

describe Puppet::Type.type(:keystone_endpoint).provider(:openstack) do

  let(:set_env) do
    ENV['OS_USERNAME']     = 'test'
    ENV['OS_PASSWORD']     = 'abc123'
    ENV['OS_PROJECT_NAME'] = 'test'
    ENV['OS_AUTH_URL']     = 'http://127.0.0.1:5000'
  end

  describe 'when managing an endpoint' do

    let(:endpoint_attrs) do
      {
        :title        => 'region/endpoint',
        :ensure       => 'present',
        :public_url   => 'http://127.0.0.1:5000',
        :internal_url => 'http://127.0.0.1:5001',
        :admin_url    => 'http://127.0.0.1:5002'
      }
    end

    let(:resource) do
      Puppet::Type::Keystone_endpoint.new(endpoint_attrs)
    end

    let(:provider) do
      described_class.new(resource)
    end

    before(:each) do
      set_env
      described_class.endpoints = nil
      described_class.services  = nil
    end

    describe '#create' do
      before(:each) do
        described_class.expects(:openstack)
          .with('endpoint', 'create', '--format', 'shell',
                ['service_id1', 'admin', 'http://127.0.0.1:5002', '--region', 'region'])
          .returns('admin_url="http://127.0.0.1:5002"
id="endpoint1_id"
region="region"
')
        described_class.expects(:openstack)
          .with('endpoint', 'create', '--format', 'shell',
                ['service_id1', 'internal', 'http://127.0.0.1:5001', '--region', 'region'])
          .returns('internal_url="http://127.0.0.1:5001"
id="endpoint2_id"
region="region"
')
        described_class.expects(:openstack)
          .with('endpoint', 'create', '--format', 'shell',
                ['service_id1', 'public', 'http://127.0.0.1:5000', '--region', 'region'])
          .returns('public_url="http://127.0.0.1:5000"
id="endpoint3_id"
region="region"
')
        described_class.expects(:openstack)
          .with('service', 'list', '--quiet', '--format', 'csv', [])
          .returns('"ID","Name","Type"
"service_id1","endpoint","type_one"
')
      end
      context 'without the type' do
        it 'creates an endpoint' do
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.id).to eq('endpoint1_id,endpoint2_id,endpoint3_id')
        end
      end
      context 'with the type' do
        let(:endpoint_attrs) do
          {
            :title        => 'region/endpoint',
            :ensure       => 'present',
            :public_url   => 'http://127.0.0.1:5000',
            :internal_url => 'http://127.0.0.1:5001',
            :admin_url    => 'http://127.0.0.1:5002',
            :type         => 'type_one'
          }
        end

        it 'creates an endpoint' do
          provider.create
          expect(provider.exists?).to be_truthy
          expect(provider.id).to eq('endpoint1_id,endpoint2_id,endpoint3_id')
        end
      end
    end

    describe '#destroy' do
      it 'destroys an endpoint' do
        provider.instance_variable_get('@property_hash')[:id] = 'endpoint1_id,endpoint2_id,endpoint3_id'
        described_class.expects(:openstack)
          .with('endpoint', 'delete', 'endpoint1_id')
        described_class.expects(:openstack)
          .with('endpoint', 'delete', 'endpoint2_id')
        described_class.expects(:openstack)
          .with('endpoint', 'delete', 'endpoint3_id')
        provider.destroy
        expect(provider.exists?).to be_falsey
      end
    end

    describe '#exists' do
      context 'when tenant does not exist' do
        subject(:response) do
          provider.exists?
        end

        it { is_expected.to be_falsey }
      end
    end

    describe '#instances' do
      it 'finds every tenant' do
        described_class.expects(:openstack)
          .with('endpoint', 'list', '--quiet', '--format', 'csv', [])
          .returns('"ID","Region","Service Name","Service Type","Enabled","Interface","URL"
"endpoint1_id","RegionOne","keystone","identity",True,"admin","http://127.0.0.1:5002"
"endpoint2_id","RegionOne","keystone","identity",True,"internal","https://127.0.0.1:5001"
"endpoint3_id","RegionOne","keystone","identity",True,"public","https://127.0.0.1:5000"
')
        instances = described_class.instances
        expect(instances.count).to eq(1)
      end
    end

    describe '#prefetch' do
      context 'working: fq or nfq and matching resource' do
        before(:each) do
          described_class.expects(:openstack)
            .with('endpoint', 'list', '--quiet', '--format', 'csv', [])
            .returns('"ID","Region","Service Name","Service Type","Enabled","Interface","URL"
"endpoint1_id","RegionOne","keystone","identity",True,"admin","http://127.0.0.1:5002"
"endpoint2_id","RegionOne","keystone","identity",True,"internal","https://127.0.0.1:5001"
"endpoint3_id","RegionOne","keystone","identity",True,"public","https://127.0.0.1:5000"
')
        end
        context '#fq resource in title' do
          let(:resources) do
            [Puppet::Type.type(:keystone_endpoint).new(:title => 'RegionOne/keystone::identity', :ensure => :present),
              Puppet::Type.type(:keystone_endpoint).new(:title => 'RegionOne/keystone::identityv3', :ensure => :present)]
          end
          include_examples 'prefetch the resources'
        end
        context '#fq resource' do
          let(:resources) do
            [Puppet::Type.type(:keystone_endpoint).new(:title => 'keystone', :region => 'RegionOne', :type => 'identity', :ensure => :present),
              Puppet::Type.type(:keystone_endpoint).new(:title => 'RegionOne/keystone::identityv3', :ensure => :present)]
          end
          include_examples 'prefetch the resources'
        end
        context '#nfq resource in title matching existing endpoint' do
          let(:resources) do
            [Puppet::Type.type(:keystone_endpoint).new(:title => 'RegionOne/keystone', :ensure => :present),
              Puppet::Type.type(:keystone_endpoint).new(:title => 'RegionOne/keystone::identityv3', :ensure => :present)]
          end
          include_examples 'prefetch the resources'
        end
        context '#nfq resource matching existing endpoint' do
          let(:resources) do
            [Puppet::Type.type(:keystone_endpoint).new(:title => 'keystone', :region => 'RegionOne', :ensure => :present),
              Puppet::Type.type(:keystone_endpoint).new(:title => 'RegionOne/keystone::identityv3', :ensure => :present)]
          end
          include_examples 'prefetch the resources'
        end
      end

      context 'not working' do
        context 'too many type' do
          before(:each) do
            described_class.expects(:openstack)
              .with('endpoint', 'list', '--quiet', '--format', 'csv', [])
              .returns('"ID","Region","Service Name","Service Type","Enabled","Interface","URL"
"endpoint1_id","RegionOne","keystone","identity",True,"admin","http://127.0.0.1:5002"
"endpoint2_id","RegionOne","keystone","identity",True,"internal","https://127.0.0.1:5001"
"endpoint3_id","RegionOne","keystone","identity",True,"public","https://127.0.0.1:5000"
"endpoint4_id","RegionOne","keystone","identityv3",True,"admin","http://127.0.0.1:5002"
"endpoint5_id","RegionOne","keystone","identityv3",True,"internal","https://127.0.0.1:5001"
"endpoint6_id","RegionOne","keystone","identityv3",True,"public","https://127.0.0.1:5000"
')
          end
          it "should fail as it's not possible to get the right type here" do
            existing = Puppet::Type.type(:keystone_endpoint)
              .new(:title => 'RegionOne/keystone', :ensure => :present)
            resource = mock
            r = []
            r << existing

            catalog = Puppet::Resource::Catalog.new
            r.each { |res| catalog.add_resource(res) }
            m_value = mock
            m_first = mock
            resource.expects(:values).returns(m_value)
            m_value.expects(:first).returns(m_first)
            m_first.expects(:catalog).returns(catalog)
            m_first.expects(:class).returns(described_class.resource_type)
            expect { described_class.prefetch(resource) }
              .to raise_error(Puppet::Error,
                              /endpoint matching RegionOne\/keystone: identity identityv3/)
          end
        end
      end

      context 'not any type but existing service' do
        before(:each) do
          described_class.expects(:openstack)
            .with('endpoint', 'list', '--quiet', '--format', 'csv', [])
            .returns('"ID","Region","Service Name","Service Type","Enabled","Interface","URL"
"endpoint1_id","RegionOne","keystone","identity",True,"admin","http://127.0.0.1:5002"
"endpoint2_id","RegionOne","keystone","identity",True,"internal","https://127.0.0.1:5001"
"endpoint3_id","RegionOne","keystone","identity",True,"public","https://127.0.0.1:5000"
')
          described_class.expects(:openstack)
            .with('service', 'list', '--quiet', '--format', 'csv', [])
            .returns('"ID","Name","Type"
"service1_id","keystonev3","identity"
')
        end
        it 'should be successful' do
          existing = Puppet::Type.type(:keystone_endpoint)
            .new(:title => 'RegionOne/keystonev3', :ensure => :present)
          resource = mock
          r = []
          r << existing

          catalog = Puppet::Resource::Catalog.new
          r.each { |res| catalog.add_resource(res) }
          m_value = mock
          m_first = mock
          resource.expects(:values).returns(m_value)
          m_value.expects(:first).returns(m_first)
          m_first.expects(:catalog).returns(catalog)
          m_first.expects(:class).returns(described_class.resource_type)

          expect { described_class.prefetch(resource) }.not_to raise_error
          expect(existing.provider.ensure).to eq(:absent)
        end
      end
    end
  end
end
