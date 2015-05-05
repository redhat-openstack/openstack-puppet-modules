#!/usr/bin/env rspec
require 'spec_helper'

describe 'fluentd::configfile', :type => :define do
  let :pre_condition do
    'include fluentd'
  end
  let(:params) { { :content => "<love fluentd></love>" } }

  ['Debian','RedHat'].each do |osfam|
    context "When on an #{osfam} system" do
      let (:facts) {{
        :osfamily       => osfam,
        :lsbdistid      => 'Debian', # Concatlib needs this value. Works for RedHat too.
        }}
      context 'when fed no parameters' do
        let (:title) { 'MyBaconBringsAllTheBoysToTheYard'}
        context 'provides a stub config' do
          it { should contain_class('fluentd') }
          it { should contain_file("/etc/td-agent/config.d/50-#{title}.conf").with(
            'owner'   => 'td-agent',
            'group'   => 'td-agent',
            'mode'    => '0644',
            'require' => 'Class[Fluentd::Packages]'
            )
          }
        end
      end
    end
  end
end