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

      let :timezone_ensure do
        case params[:ensure]
        when /present/
          "file"
        when /absent/
          "absent"
        else
          "file"
        end
      end

      describe "on supported osfamily: RedHat" do
        let(:facts) {{ :osfamily => "RedHat" }}

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
         should contain_file('/etc/sysconfig/clock').
           with_ensure(timezone_ensure).
           with_content(/^ZONE="#{param_hash[:timezone]}"$/)
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

      describe "on supported osfamily: Debian" do
        let(:facts) {{ :osfamily => "Debian" }}

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
         should contain_file('/etc/timezone').
           with_ensure(timezone_ensure).
           with_content(/^#{param_hash[:timezone]}$/)
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
