require 'puppetlabs_spec_helper/module_spec_helper'

def valid_os_tests()
  # Confirm that module compiles
  it { should compile }
  it { should compile.with_all_deps }

  # Confirm presence of classes
  it { should contain_class('opendaylight') }
  it { should contain_class('opendaylight::params') }
  it { should contain_class('opendaylight::install') }
  it { should contain_class('opendaylight::config') }
  it { should contain_class('opendaylight::service') }

  # Confirm relationships between classes
  it { should contain_class('opendaylight::install').that_comes_before('opendaylight::config') }
  it { should contain_class('opendaylight::config').that_requires('opendaylight::install') }
  it { should contain_class('opendaylight::config').that_notifies('opendaylight::service') }
  it { should contain_class('opendaylight::service').that_subscribes_to('opendaylight::config') }
  it { should contain_class('opendaylight::service').that_comes_before('opendaylight') }
  it { should contain_class('opendaylight').that_requires('opendaylight::service') }

  # Confirm presense of other resources
  it { should contain_service('opendaylight') }
  it { should contain_yumrepo('opendaylight') }
  it { should contain_package('opendaylight') }
  it { should contain_file('org.apache.karaf.features.cfg') }

  # Confirm relationships between other resources
  it { should contain_package('opendaylight').that_requires('Yumrepo[opendaylight]') }
  it { should contain_yumrepo('opendaylight').that_comes_before('Package[opendaylight]') }

  # Confirm properties of other resources
  # There's a more elegant way to do these long sets of checks
  #   using multi-line hashes, but it breaks in Ruby 1.8.7
  it { should contain_yumrepo('opendaylight').with_enabled('1').with_gpgcheck('0').with_descr('OpenDaylight SDN controller') }
  it { should contain_package('opendaylight').with_ensure('present') }
  it { should contain_service('opendaylight').with_ensure('running').with_enable('true').with_hasstatus('true').with_hasrestart('true') }
  it { should contain_file('org.apache.karaf.features.cfg').with_ensure('file').with_path('/opt/opendaylight-0.2.1/etc/org.apache.karaf.features.cfg') }
end

