require 'spec_helper'

describe 'common::remove_if_empty' do
  context 'should create new directory' do
    let(:title) { '/some/dir/structure' }

    it {
      should contain_exec('remove_if_empty-/some/dir/structure').with({
        'command' => 'rm -f /some/dir/structure',
        'unless'  => 'test -f /some/dir/structure; if [ $? == \'0\' ]; then test -s /some/dir/structure; fi',
        'path'    => '/bin:/usr/bin:/sbin:/usr/sbin',
      })
    }
  end

  context 'should fail with a path that is not absolute' do
    let(:title) { 'not/a/valid/absolute/path' }

    it do
      expect {
        should contain_exec('remove_if_empty-not/a/valid/absolute/path')
      }.to raise_error(Puppet::Error)
    end
  end
end
