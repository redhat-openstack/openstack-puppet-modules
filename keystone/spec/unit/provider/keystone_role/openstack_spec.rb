require 'puppet'
require 'spec_helper'
require 'puppet/provider/keystone_role/openstack'

provider_class = Puppet::Type.type(:keystone_role).provider(:openstack)

describe provider_class do

  describe 'when creating a role' do

    let(:role_attrs) do
      {
        :name         => 'foo',
        :ensure       => 'present',
        :auth         => {
          'username'     => 'test',
          'password'     => 'abc123',
          'project_name' => 'foo',
          'auth_url'     => 'http://127.0.0.1:5000/v2.0',
        }
      }
    end

    let(:resource) do
      Puppet::Type::Keystone_role.new(role_attrs)
    end

    let(:provider) do
      provider_class.new(resource)
    end

    describe '#create' do
      it 'creates a role' do
        provider.class.stubs(:openstack)
                      .with('role', 'list', '--quiet', '--format', 'csv', [['--os-username', 'test', '--os-password', 'abc123', '--os-project-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name"
"1cb05cfed7c24279be884ba4f6520262","foo"
')
        provider.class.stubs(:openstack)
                      .with('role', 'create', '--format', 'shell', [['foo', '--os-username', 'test', '--os-password', 'abc123', '--os-project-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('name="foo"')
        provider.create
        expect(provider.exists?).to be_truthy
      end
    end

    describe '#destroy' do
      it 'destroys a role' do
        provider.class.stubs(:openstack)
                      .with('role', 'list', '--quiet', '--format', 'csv', [['--os-username', 'test', '--os-password', 'abc123', '--os-project-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name"')
        provider.class.stubs(:openstack)
                      .with('role', 'delete', [['foo', '--os-username', 'test', '--os-password', 'abc123', '--os-project-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
        provider.destroy
        expect(provider.exists?).to be_falsey
      end

    end

    describe '#exists' do
      context 'when role exists' do

        subject(:response) do
          provider.class.stubs(:openstack)
                        .with('role', 'list', '--quiet', '--format', 'csv', [['--os-username', 'test', '--os-password', 'abc123', '--os-project-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                        .returns('"ID","Name"
"1cb05cfed7c24279be884ba4f6520262","foo"
')
          response = provider.exists?
        end

        it { is_expected.to be_truthy }
      end

      context 'when role does not exist' do

        subject(:response) do
          provider.class.stubs(:openstack)
                        .with('role', 'list', '--quiet', '--format', 'csv', [['--os-username', 'test', '--os-password', 'abc123', '--os-project-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name"')
          response = provider.exists?
        end

        it { is_expected.to be_falsey }
      end
    end

    describe '#instances' do
      it 'finds every role' do
        provider.class.stubs(:openstack)
                      .with('role', 'list', '--quiet', '--format', 'csv', [['--os-username', 'test', '--os-password', 'abc123', '--os-project-name', 'foo', '--os-auth-url', 'http://127.0.0.1:5000/v2.0']])
                      .returns('"ID","Name"
"1cb05cfed7c24279be884ba4f6520262","foo"
')
        instances = provider.instances
        expect(instances.count).to eq(1)
      end
    end

  end
end
