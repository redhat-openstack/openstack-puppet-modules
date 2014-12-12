require 'spec_helper'

describe 'common::mkdir_p' do
  context 'should create new directory' do
    let(:title) { '/some/dir/structure' }

    it {
      should contain_exec('mkdir_p-/some/dir/structure').with({
        'command' => 'mkdir -p /some/dir/structure',
        'unless'  => 'test -d /some/dir/structure',
      })
    }
  end

  context 'should fail with a path that is not absolute' do
    let(:title) { 'not/a/valid/absolute/path' }

    it do
      expect {
        should contain_exec('mkdir_p-not/a/valid/absolute/path').with({
          'command' => 'mkdir -p not/a/valid/absolute/path',
          'unless'  => 'test -d not/a/valid/absolute/path',
        })
      }.to raise_error(Puppet::Error)
    end
  end
end
