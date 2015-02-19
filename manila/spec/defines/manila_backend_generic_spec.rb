require 'spec_helper'

describe 'manila::backend::generic' do

  let(:title) {'hippo'}

  let :params do
    {
      :smb_template_config_path         => '$state_path/smb.conf',
      :volume_name_template             => 'manila-share-%s',
      :volume_snapshot_name_template    => 'manila-snapshot-%s',
      :share_mount_path                 => '/shares',
      :max_time_to_create_volume        => 180,
      :max_time_to_attach               => 120,
      :service_instance_smb_config_path => '$share_mount_path/smb.conf',
      :share_volume_fstype              => 'ext4',
    }
  end

  describe 'generic share driver' do

    it 'configures generic share driver' do
      should contain_manila_config('hippo/share_backend_name').with(
        :value => 'hippo')
      should contain_manila_config('hippo/share_driver').with_value(
        'manila.share.drivers.generic.GenericShareDriver')
      should contain_manila_config('hippo/share_helpers').with_value(
	'CIFS=manila.share.drivers.generic.CIFSHelper,'\
        'NFS=manila.share.drivers.generic.NFSHelper')
      params.each_pair do |config,value|
        should contain_manila_config("hippo/#{config}").with_value( value )
      end
    end
  end
end
