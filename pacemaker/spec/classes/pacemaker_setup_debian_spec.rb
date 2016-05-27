require 'spec_helper'

describe 'pacemaker::new::setup::debian', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pacemaker::new::params') }

        it { is_expected.to contain_class('pacemaker::new::setup::debian') }

        it { is_expected.to contain_file('corosync-service-dir').with_ensure('directory').with_path('/etc/corosync/service.d') }

        service_file = <<-eof
service {
    # Load the Pacemaker Cluster Resource Manager
    name: pacemaker
    ver:  1
}
        eof

        service_file_parameters = {
            path: '/etc/corosync/service.d/pacemaker',
            content: service_file,
        }

        it { is_expected.to contain_file('corosync-service-pacemaker').with(service_file_parameters) }

        it { is_expected.to contain_file('corosync-debian-default') }

        it { is_expected.to contain_file('pacemaker-debian-default') }

        it { is_expected.to contain_file('cman-debian-default') }

      end

    end
  end
end
