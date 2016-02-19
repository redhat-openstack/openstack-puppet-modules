shared_examples_for "a Puppet::Error" do |description|
  it "with message matching #{description.inspect}" do
    expect { is_expected.to have_class_count(1) }.to raise_error(Puppet::Error, description)
  end
end

shared_examples_for 'basic_setup' do |packages, pcsd_mode|
  packages.each do |p|
    it { is_expected.to contain_package(p) }
  end
  service_name = pcsd_mode ? 'pcsd' : 'pacemaker'
  it { is_expected.to contain_service(service_name)
                       .with('ensure'     => 'running',
                             'hasstatus'  => true,
                             'hasrestart' => true,
                             'enable'     => true)
                       .that_requires('Class[pacemaker::install]')
  }
end
