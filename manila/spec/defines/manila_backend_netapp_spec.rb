require 'spec_helper'

describe 'manila::backend::netapp' do

  let(:title) {'mynetapp'}

  let :params do
    {
      :driver_handles_share_servers        => true,
      :netapp_login                        => 'netapp',
      :netapp_password                     => 'password',
      :netapp_server_hostname              => '127.0.0.2',
      :netapp_server_port                  => '443',
      :netapp_vserver                      => 'manilasvm',
      :netapp_root_volume_aggregate        => 'aggr1',
      :netapp_trace_flags                  => 'method,api',
    }
  end

  let :default_params do
    {
      :netapp_transport_type                => 'http',
      :netapp_storage_family                => 'ontap_cluster',
      :netapp_volume_name_template          => 'share_%(share_id)s',
      :netapp_vserver_name_template         => 'os_%s',
      :netapp_lif_name_template             => 'os_%(net_allocation_id)s',
      :netapp_aggregate_name_search_pattern => '(.*)',
      :netapp_root_volume_name              => 'root',
      :netapp_port_name_search_pattern      => '(.*)',
    }
  end

  shared_examples_for 'netapp share driver' do
    let :params_hash do
      default_params.merge(params)
    end

    it 'configures netapp share driver' do
      is_expected.to contain_manila_config("mynetapp/share_driver").with_value(
        'manila.share.drivers.netapp.common.NetAppDriver')
      params_hash.each_pair do |config,value|
        is_expected.to contain_manila_config("mynetapp/#{config}").with_value( value )
      end
    end

    it 'marks netapp_password as secret' do
      is_expected.to contain_manila_config("mynetapp/netapp_password").with_secret( true )
    end
  end


  context 'with default parameters' do
    before do
      params = {}
    end

    it_configures 'netapp share driver'
  end

  context 'with provided parameters' do
    it_configures 'netapp share driver'
  end

  context 'with share server config' do
    before do
      params.merge!({
        :netapp_password => true,
      })
    end

    it { is_expected.to raise_error(Puppet::Error, /true is not a string.  It looks to be a TrueClass/) }
  end

end
