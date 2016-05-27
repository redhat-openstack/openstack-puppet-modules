require 'spec_helper'

describe 'pacemaker::new::firewall', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'corosync with default parameters' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pacemaker::new::firewall') }

        it { is_expected.to contain_class('pacemaker::new::params') }

        ipv4_parameters = {
            proto: 'udp',
            dport: %w(5404 5405),
            action: 'accept',
        }
        it { is_expected.to contain_firewall('001 corosync mcast').with(ipv4_parameters) }

        ipv6_parameters = {
            proto: 'udp',
            dport: %w(5404 5405),
            action: 'accept',
            provider: 'ip6tables',
        }
        it { is_expected.to contain_firewall('001 corosync mcast ipv6').with(ipv6_parameters) }
      end

      context 'pcsd with default parameters' do
        let(:params) do
          {
              firewall_pcsd_manage: true,
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pacemaker::new::firewall') }

        it { is_expected.to contain_class('pacemaker::new::params') }

        ipv4_parameters = {
            proto: 'tcp',
            dport: %w(2224),
            action: 'accept',
        }
        it { is_expected.to contain_firewall('001 pcsd').with(ipv4_parameters) }

        ipv6_parameters = {
            proto: 'tcp',
            dport: %w(2224),
            action: 'accept',
            provider: 'ip6tables',
        }
        it { is_expected.to contain_firewall('001 pcsd ipv6').with(ipv6_parameters) }
      end

      context 'corosync with custom parameters' do
        let(:params) do
          {
              firewall_corosync_proto: 'tcp',
              firewall_corosync_dport: %w(80 443),
              firewall_corosync_action: 'reject',
              firewall_ipv6_manage: false,
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pacemaker::new::firewall') }

        it { is_expected.to contain_class('pacemaker::new::params') }

        ipv4_parameters = {
            proto: 'tcp',
            dport: %w(80 443),
            action: 'reject',
        }
        it { is_expected.to contain_firewall('001 corosync mcast').with(ipv4_parameters) }

        it { is_expected.not_to contain_firewall('001 corosync mcast ipv6') }
      end

      context 'pcs with custom parameters' do
        let(:params) do
          {
              firewall_pcsd_manage: true,
              firewall_pcsd_dport: %w(2225),
              firewall_pcsd_action: 'reject',
              firewall_ipv6_manage: false,
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pacemaker::new::firewall') }

        it { is_expected.to contain_class('pacemaker::new::params') }

        ipv4_parameters = {
            proto: 'tcp',
            dport: %w(2225),
            action: 'reject',
        }
        it { is_expected.to contain_firewall('001 pcsd').with(ipv4_parameters) }

        it { is_expected.not_to contain_firewall('001 pcsd ipv6') }
      end

      context 'corosync manage disabled' do
        let(:params) do
          {
              firewall_corosync_manage: false,
          }
        end

        it { is_expected.not_to contain_firewall('001 corosync mcast') }

        it { is_expected.not_to contain_firewall('001 corosync mcast ipv6') }
      end

      context 'pcsd manage disabled' do
        let(:params) do
          {
              firewall_pcsd_manage: false,
          }
        end

        it { is_expected.not_to contain_firewall('001 pcsd') }

        it { is_expected.not_to contain_firewall('001 pcsd ipv6') }
      end

    end
  end
end
