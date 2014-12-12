require 'spec_helper'

describe 'keepalived::instance', :type => :define do

  let :title do
    'something'
  end

  let :default_params do
    {
      :interface     => 'eth0',
      :virtual_ips   => [ '10.0.0.1 dev bond0.X' ],
      :state         => 'BACKUP',
      :state         => 'BACKUP',
      :priority      => 1,
      :name          => 'something',
    }
  end

  let :fragment_file do
    '/var/lib/puppet/concat/_etc_keepalived_keepalived.conf/fragments/50_keepalived_something'
  end

  let :facts do
    {
      :concat_basedir => '/var/lib/puppet/concat'
    }
  end

  let :pre_condition do
    'class { "concat::setup": }
     concat { "/etc/keepalived/keepalived.conf": }'
  end


  describe 'when passing default parameters' do
    let :params do
      default_params
    end

    it 'should build the fragment with correct content' do
      verify_contents(subject, fragment_file,
        [
"vrrp_instance something {", "  virtual_router_id something", "", "  # Advert interval", "  advert_int 1", "  # for electing MASTER, highest priority wins.", "  priority  1", "  state     BACKUP", "  interface eth0", "  virtual_ipaddress {", "  ", "      10.0.0.1 dev bond0.X", "  }", "}"
        ]
      )
    end
  end


  describe 'when passing duplicated IP addresses' do
    let :params do
      default_params.merge(:virtual_ips   => [ '10.0.0.1 dev bond0.X', '10.0.0.1 dev bond0.X', '10.0.0.2 dev bond1.X' ])
    end
    it 'it should only keep the first one' do
      should contain_file(fragment_file)\
       .with_content(
         "vrrp_instance something {\n  virtual_router_id something\n\n  # Advert interval\n  advert_int 1\n\n  # for electing MASTER, highest priority wins.\n  priority  1\n  state     BACKUP\n\n  interface eth0\n\n  virtual_ipaddress {\n  \n      10.0.0.1 dev bond0.X\n      10.0.0.2 dev bond1.X\n  \n  \n  }\n    \n  \n  \n  \n\n  \n  \n}\n"
       )
    end
  end

end

