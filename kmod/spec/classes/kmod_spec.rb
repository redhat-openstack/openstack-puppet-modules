require 'spec_helper'

describe 'kmod', :type => :class do
  it { should contain_class('kmod') }
  it { should contain_file('/etc/modprobe.d').with({ 'ensure' => 'directory' }) }
  ['modprobe.conf','aliases.conf','blacklist.conf'].each do |file|
    it { should contain_file("/etc/modprobe.d/#{file}").with({ 'ensure' => 'present' }) }
  end
end
