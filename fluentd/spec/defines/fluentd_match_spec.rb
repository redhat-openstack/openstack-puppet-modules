#!/usr/bin/env rspec
require 'spec_helper'

describe 'fluentd::match' do
	let(:title) {'bar'}

    let (:facts) {{
	    :osfamily       => 'Debian',
	    :concat_basedir => '/dne',
	    :lsbdistid      => 'Debian', 
    }}

    context "when no servers or out_copy" do
    	let(:params) {{
        :configfile => 'foo',
        :pattern    => 'baz',
        :type		=> 'file',
        :config     => {
            'time_slice_wait'   => '10m',
            'compress'          => 'gzip',
        }
		}}

		it "should create matcher single segment" do
			should contain_concat__fragment('match_bar').with_content(/<match baz>.*type.*file.*compress.*gzip.*time_slice_wait.*10m.*<\/match>/m)
			should_not contain_concat__fragment('match_bar').with_content(/server/)
			should_not contain_concat__fragment('match_bar').with_content(/store/)
		end
	end

    context "when servers but no out_copy" do
    	let(:params) {{
        :configfile => 'foo',
        :pattern    => 'baz',
        :type		=> 'file',
        :servers    => [{ 'host' => 'kelis', 'port' => '24224'}, { 'host' => 'bossy', 'port' => '24224'}],
        :config     => {
            'time_slice_wait'   => '10m',
            'compress'          => 'gzip',
        }
		}}

		it "should create matcher with server" do
			should contain_concat__fragment('match_bar').with_content(/<match baz>.*type.*file.*compress.*gzip.*time_slice_wait.*10m.*<server>.*host kelis.*port.*24224.*<\/server>.*<server>.*host.*bossy.*port.*24224.*<\/server>.*<\/match>/m)
			should contain_concat__fragment('match_bar').with_content(/server/)
			should_not contain_concat__fragment('match_bar').with_content(/store/)
		end
	end

    context "when out_copy" do
    	let(:params) {{
        :configfile => 'foo',
        :pattern    => 'baz',
        :type		=> 'copy',
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
			should contain_concat__fragment('match_bar').with_content(/<match baz>.*type.*copy.*<store>.*compress.*gzip.*<server>.*host.*kelis.*port.*24224.*<\/server>.*<server>.*host.*bossy.*port.*24224.*<\/server>.*type.*file.*<\/store>.*<store>.*database.*dummy.*type.*mongo.*<\/store>.*<\/match>/m)
		end
	end


end


