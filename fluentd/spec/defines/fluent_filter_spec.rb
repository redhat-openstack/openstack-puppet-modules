#!/usr/bin/env rspec
require 'spec_helper'

describe 'fluentd::filter' do
    let(:title) {'bar'}

    let (:facts) {{
      :osfamily       => 'Debian',
      :lsbdistid      => 'Debian', 
    }}

    context "when type is grep" do
      let(:params) {{
        :pattern            => 'baz',
        :config             => {
          'type'               => 'grep',
          'input_key'          => 'input_key',
          'regexp'             => '/regex/',
          'exclude'            => 'exclude',
          'output_tag'         => 'output_tag',
          'add_tag_prefix'     => 'add_tag_prefix',
          'remove_tag_prefix'  => 'remove_tag_prefix',
          'add_tag_suffix'     => 'add_tag_suffix',
          'remove_tag_suffix'  => 'remove_tag_suffix',
        },
    }}

    it "should install the grep plugin" do
      should contain_fluentd__install_plugin('fluent-plugin-grep')
    end


    it "should create matcher single segment" do
      should contain_fluentd__configfile('filter-bar').with_content(/<match baz>.*type.*input_key.*regexp.*exclude.*output_tag.*add_tag_prefix.*remove_tag_prefix.*add_tag_suffix.*remove_tag_suffix.*<\/match>/m)
    end
  end

end