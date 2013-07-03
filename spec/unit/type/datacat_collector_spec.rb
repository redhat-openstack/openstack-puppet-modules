require 'spec_helper'

describe Puppet::Type.type(:datacat_collector) do
  context "simple merging" do
    before :each do
      @catalog = Puppet::Resource::Catalog.new
      @file = Puppet::Type.type(:file).new(:path => '/test')
      @catalog.add_resource @file

      @collector = Puppet::Type.type(:datacat_collector).new(
        :title => "/test",
        :template_body => '<%= @data.keys.sort.map { |x| "#{x}=#{@data[x]}" }.join(",") %>',
        :before => @file.to_s,
      )
      @catalog.add_resource @collector
    end

    it "should do work when exists?" do
      @file.expects(:[]=).with(:content, "")
      @collector.provider.exists?
    end

    it "should combine one hash" do
      @catalog.add_resource Puppet::Type.type(:datacat_fragment).new(
        :title => "hash one",
        :target => '/test',
        :data => { "foo" => "one" },
      )

      @file.expects(:[]=).with(:content, "foo=one")
      @collector.provider.exists?
    end

    it "should combine two hashes, disjunct keys" do
      @catalog.add_resource Puppet::Type.type(:datacat_fragment).new(
        :title => "hash one",
        :target => '/test',
        :data => { "alpha" => "one" },
      )
      @catalog.add_resource Puppet::Type.type(:datacat_fragment).new(
        :title => "hash two",
        :target => '/test',
        :data => { "bravo" => "two" },
      )

      @file.expects(:[]=).with(:content, "alpha=one,bravo=two")
      @collector.provider.exists?
    end

    it "should combine two hashes, overlapping keys" do
      @catalog.add_resource Puppet::Type.type(:datacat_fragment).new(
        :title => "hash one",
        :target => '/test',
        :data => { "alpha" => "one" },
      )
      @catalog.add_resource Puppet::Type.type(:datacat_fragment).new(
        :title => "hash two",
        :target => '/test',
        :data => { "alpha" => "two" },
      )

      @file.expects(:[]=).with(:content, "alpha=two")
      @collector.provider.exists?
    end
  end
end
