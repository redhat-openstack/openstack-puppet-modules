require 'spec_helper'
describe 'timezone' do

  let :default_params do
    {
      :ensure      => 'present',
      :timezone    => 'UTC',
      :autoupgrade => false,
    }
  end

  [ {},
    {
      :ensure      => 'present',
      :timezone    => 'Europe/Berlin',
      :autoupgrade => false,
    },
    {
      :ensure      => 'present',
      :timezone    => 'UTC',
      :autoupgrade => true,
    }
  ].each do |param_set|
    describe "when #{param_set == {} ? "using default" : "specifying"} class parameters" do

      let :param_hash do
        default_params.merge(param_set)
      end

      let :params do
        param_set
      end

      ['Debian', 'Redhat'].each do |osfamily|

        let :facts do
          {
            :osfamily        => osfamily,
          }
        end

        describe "on supported osfamily: #{osfamily}" do

          it { should contain_class('timezone::params') }

          it { 
            if not param_hash[:autoupgrade]
              should contain_package('tzdata').with_ensure(param_hash[:ensure])
            end
          }

          it {
            if param_hash[:autoupgrade]
              should contain_package('tzdata').with_ensure('latest')
            end
          }

          it {
            if param_hash[:ensure] == 'present'
              should contain_file('/etc/localtime').with(
                'ensure' => 'link',
                'target' => "/usr/share/zoneinfo/#{param_hash[:timezone]}"
              )
            end
          }
        end
      end
    end
  end
end
