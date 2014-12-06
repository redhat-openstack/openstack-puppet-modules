require 'spec_helper'

describe 'manila::share::netapp' do

  let :params do
    {
      :netapp_nas_login             => 'netapp',
      :netapp_nas_password          => 'password',
      :netapp_nas_server_hostname   => '127.0.0.2',
      :netapp_root_volume_aggregate => 'aggr1',
    }
  end

  let :default_params do
    {
      :netapp_nas_transport_type            => 'http',
      :netapp_nas_volume_name_template      => 'share_%(share_id)s',
      :netapp_vserver_name_template         => 'os_%s',
      :netapp_lif_name_template             => 'os_%(net_allocation_id)s',
      :netapp_aggregate_name_search_pattern => '(.*)',
      :netapp_root_volume_name              => 'root',
    }
  end


  shared_examples_for 'netapp share driver' do
    let :params_hash do
      default_params.merge(params)
    end

    it 'configures netapp share driver' do
      should contain_manila_config('DEFAULT/share_driver').with_value(
        'manila.share.drivers.netapp.cluster_mode.NetAppClusteredShareDriver')
      params_hash.each_pair do |config,value|
        should contain_manila_config("DEFAULT/#{config}").with_value( value )
      end
    end

    it 'marks netapp_password as secret' do
      should contain_manila_config('DEFAULT/netapp_nas_password').with_secret( true )
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
end
