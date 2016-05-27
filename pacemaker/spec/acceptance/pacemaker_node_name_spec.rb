require 'spec_helper_acceptance'

describe 'pacemaker_node_name' do
  pp = <<-eof
file { '/tmp/pacemaker_node_name' :
  ensure  => 'present',
  content => $::pacemaker_node_name,
}
  eof

  include_examples 'manifest', pp

  describe file('/tmp/pacemaker_node_name') do
    it { is_expected.to be_file }
    its(:size) { is_expected.to be > 0 }
    its(:content) { is_expected.to contain('node') }
  end
end
