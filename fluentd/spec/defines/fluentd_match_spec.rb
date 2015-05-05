#!/usr/bin/env rspec
require 'spec_helper'

describe 'fluentd::match' do
	let(:title) {'bar'}

    let (:facts) {{
	    :osfamily       => 'Debian',
	    :lsbdistid      => 'Debian', 
    }}

    context "when no servers or out_copy" do
    	let(:params) {{
        :pattern    => 'baz',
        :config     => {
            'type'              => 'file',
            'time_slice_wait'   => '10m',
            'compress'          => 'gzip',
        }
		}}

		it "should create matcher single segment" do
            should contain_fluentd__configfile('match-bar').with_content(/<match baz>.*type.*file.*time_slice_wait.*10m.*compress.*gzip.*<\/match>/m)
			should_not contain_fluentd__configfile('match-bar').with_content(/server/)
			should_not contain_fluentd__configfile('match-bar').with_content(/store/)
		end
	end

    context "when servers but no out_copy" do
    	let(:params) {{
        :pattern    => 'baz',
        :config     => {
            'servers'    => [{ 'host' => 'kelis', 'port' => '24224'}, { 'host' => 'bossy', 'port' => '24224'}],
            'type'              => 'file',
            'time_slice_wait'   => '10m',
            'compress'          => 'gzip',
        }
		}}

		it "should create matcher with server" do
            should contain_fluentd__configfile('match-bar').with_content(/<match baz>.*<server>.*host kelis.*port.*24224.*<\/server>.*<server>.*host.*bossy.*port.*24224.*<\/server>.*type.*file.*time_slice_wait.*10m.*compress.*gzip.*<\/match>/m)
			should contain_fluentd__configfile('match-bar').with_content(/server/)
			should_not contain_fluentd__configfile('match-bar').with_content(/store/)
		end
	end

    context "when out_copy" do
    	let(:params) {{
        :pattern    => 'baz',
        :config     => [
            {
                'type'              => 'file',
                'compress'          => 'gzip',
                'servers'           => [{ 'host' => 'kelis', 'port' => '24224'}, { 'host' => 'bossy', 'port' => '24224'}],
            },
            {
                'type'              => 'mongo',
                'database'          => 'dummy',
            }
        ]
		}}

		it "should create matcher with server" do
			should contain_fluentd__configfile('match-bar').with_content(/<match baz>.*type.*copy.*<store>.*type.*file.*compress.*gzip.*<server>.*host.*kelis.*port.*24224.*<\/server>.*<server>.*host.*bossy.*port.*24224.*<\/server>.*<\/store>.*<store>.*type.*mongo.*database.*dummy.*<\/store>.*<\/match>/m)
        end
	end


end


