require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_endpoint/openstack'

provider_class = Puppet::Type.type(:keystone_endpoint).provider(:openstack)

describe provider_class do

  describe 'when updating an endpoint' do

    let(:endpoint_attrs) do
      {
        :name         => 'foo/bar',
        :ensure       => 'present',
        :public_url   => 'http://127.0.0.1:5000/v2.0',
        :internal_url => 'http://127.0.0.1:5001/v2.0',
        :admin_url    => 'http://127.0.0.1:5002/v2.0',
        :auth         => {
          'username'    => 'test',
          'password'    => 'abc123',
          'tenant_name' => 'foo',
          'auth_url'    => 'http://127.0.0.1:5000/v2.0',
        }
      }
    end

    let(:resource) do
      Puppet::Type::Keystone_endpoint.new(endpoint_attrs)
    end

    let(:provider) do
      provider_class.new(resource)
    end

    describe '#create' do
      it 'creates an endpoint' do
        provider.class.stubs(:openstack)
                      .with('endpoint', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Region","Service Name","Service Type","PublicURL","AdminURL","InternalURL"
"1cb05cfed7c24279be884ba4f6520262","foo","bar","","http://127.0.0.1:5000/v2.0","http://127.0.0.1:5001/v2.0","http://127.0.0.1:5002/v2.0"
')
        provider.class.stubs(:openstack)
                      .with('endpoint', 'create', [['bar', '--region', 'foo', '--publicurl', 'http://127.0.0.1:5000/v2.0', '--internalurl', 'http://127.0.0.1:5001/v2.0', '--adminurl', 'http://127.0.0.1:5002/v2.0', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
        provider.create
        expect(provider.exists?).to be_truthy
      end
    end

    describe '#destroy' do
      it 'destroys an endpoint' do
        provider.class.stubs(:openstack)
                      .with('endpoint', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Region","Service Name","Service Type","PublicURL","AdminURL","InternalURL"
"1cb05cfed7c24279be884ba4f6520262","foo","bar","","http://127.0.0.1:5000/v2.0","http://127.0.0.1:5001/v2.0","http://127.0.0.1:5002/v2.0"
')
        provider.class.stubs(:openstack)
                      .with('endpoint', 'delete', [['1cb05cfed7c24279be884ba4f6520262', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
        expect(provider.destroy).to be_nil # We don't really care that it's nil, only that it runs successfully
      end

    end

    describe '#exists' do
      context 'when endpoint exists' do

        subject(:response) do
          provider.class.stubs(:openstack)
                        .with('endpoint', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                        .returns('"ID","Region","Service Name","Service Type","PublicURL","AdminURL","InternalURL"
"1cb05cfed7c24279be884ba4f6520262","foo","bar","","http://127.0.0.1:5000/v2.0","http://127.0.0.1:5001/v2.0","http://127.0.0.1:5002/v2.0"
')
          response = provider.exists?
        end

        it { is_expected.to be_truthy }
      end

      context 'when tenant does not exist' do

        subject(:response) do
          provider.class.stubs(:openstack)
                        .with('endpoint', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                        .returns('"ID","Region","Service Name","Service Type","PublicURL","AdminURL","InternalURL"')
          response = provider.exists?
        end

        it { is_expected.to be_falsey }
      end
    end

    describe '#instances' do
      it 'finds every tenant' do
        provider.class.stubs(:openstack)
                      .with('endpoint', 'list', '--quiet', '--format', 'csv', [['--long', '--os-username', 'test', '--os-password', 'abc123', '--os-tenant-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Region","Service Name","Service Type","PublicURL","AdminURL","InternalURL"
"1cb05cfed7c24279be884ba4f6520262","foo","bar","","http://127.0.0.1:5000/v2.0","http://127.0.0.1:5001/v2.0","http://127.0.0.1:5002/v2.0"
')
        instances = provider.instances
        expect(instances.count).to eq(1)
      end
    end

  end
end
