require 'spec_helper'

describe 'cinder::quota' do
  let :default_params do
    { :quota_volumes   => '<SERVICE DEFAULT>',
      :quota_snapshots => '<SERVICE DEFAULT>',
      :quota_gigabytes => '<SERVICE DEFAULT>',
      :quota_driver    => '<SERVICE DEFAULT>' }
  end

  let :params do
    {}
  end

  shared_examples_for 'cinder quota' do

    let :p do
      default_params.merge(params)
    end

    it 'contains default values' do
      is_expected.to contain_cinder_config('DEFAULT/quota_volumes').with_value(p[:quota_volumes])
      is_expected.to contain_cinder_config('DEFAULT/quota_snapshots').with_value(p[:quota_snapshots])
      is_expected.to contain_cinder_config('DEFAULT/quota_gigabytes').with_value(p[:quota_gigabytes])
      is_expected.to contain_cinder_config('DEFAULT/quota_driver').with_value(p[:quota_driver])
    end

    context 'configure quota with parameters' do
      before :each do
        params.merge!({ :quota_volumes => 1000,
          :quota_snapshots => 1000,
          :quota_gigabytes => 100000 })
      end

      it 'contains overrided values' do
        is_expected.to contain_cinder_config('DEFAULT/quota_volumes').with_value(p[:quota_volumes])
        is_expected.to contain_cinder_config('DEFAULT/quota_snapshots').with_value(p[:quota_snapshots])
        is_expected.to contain_cinder_config('DEFAULT/quota_gigabytes').with_value(p[:quota_gigabytes])
        is_expected.to contain_cinder_config('DEFAULT/quota_driver').with_value(p[:quota_driver])
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({ :osfamily => 'Debian' })
    end

    it_configures 'cinder quota'
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge({ :osfamily => 'RedHat' })
    end

    it_configures 'cinder quota'
  end

end
