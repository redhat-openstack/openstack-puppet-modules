require 'spec_helper'

describe 'gnocchi::db::mysql' do
  shared_examples_for 'gnocchi::db::mysql' do
    let :pre_condition do
      'include mysql::server'
    end

    describe "with default params" do
      let :params do
        {
          :password => 'gnocchipass1',
        }
      end

      it { is_expected.to contain_openstacklib__db__mysql('gnocchi').with(
        :password_hash => '*C13FFB03C3674F278DF1673D0DA7FB1EF58899F0',
        :charset       => 'utf8',
        :collate       => 'utf8_general_ci',
      )}

    end

    describe "overriding default params" do
      let :params do
        {
          :password       => 'gnocchipass2',
          :dbname         => 'gnocchidb2',
          :charset        => 'utf8',
        }
      end

      it { is_expected.to contain_openstacklib__db__mysql('gnocchi').with(
        :password_hash => '*CE931F98EEC20A712654BF67B17E413F3FE69089',
        :dbname        => 'gnocchidb2',
        :charset       => 'utf8'
      )}

    end

    describe "overriding allowed_hosts param to array" do
      let :params do
        {
          :password       => 'gnocchipass2',
          :dbname         => 'gnocchidb2',
          :allowed_hosts  => ['127.0.0.1','%']
        }
      end

      it { is_expected.to contain_openstacklib__db__mysql('gnocchi').with(
        :password_hash => '*CE931F98EEC20A712654BF67B17E413F3FE69089',
        :dbname        => 'gnocchidb2',
        :allowed_hosts => ['127.0.0.1','%']
      )}

    end

    describe "overriding allowed_hosts param to string" do
      let :params do
        {
          :password       => 'gnocchipass2',
          :dbname         => 'gnocchidb2',
          :allowed_hosts  => '192.168.1.1'
        }
      end

      it { is_expected.to contain_openstacklib__db__mysql('gnocchi').with(
        :password_hash => '*CE931F98EEC20A712654BF67B17E413F3FE69089',
        :dbname        => 'gnocchidb2',
        :allowed_hosts => '192.168.1.1'
      )}
    end

    describe "overriding allowed_hosts param equals to host param " do
      let :params do
        {
          :password       => 'gnocchipass2',
          :dbname         => 'gnocchidb2',
          :allowed_hosts  => '127.0.0.1'
        }
      end

      it { is_expected.to contain_openstacklib__db__mysql('gnocchi').with(
        :password_hash => '*CE931F98EEC20A712654BF67B17E413F3FE69089',
        :dbname        => 'gnocchidb2',
        :allowed_hosts => '127.0.0.1'
      )}
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'gnocchi::db::mysql'
    end
  end
end
