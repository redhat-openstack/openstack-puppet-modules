require 'spec_helper'

describe 'kmod::generic', :type => :define do
  let(:title) { 'install foo' }
  let(:default_params) do { :type => 'install', :module => 'foo', :file => 'modprobe.conf' } end
  let(:params) do default_params end
  it { should include_class('kmod') }
  
  context 'install foo module' do
    let(:params) do default_params end 
    it { should contain_kmod__generic('install foo') }
  
    context 'with ensure set to present' do
      it { should contain_kmod__load('foo').with({
        'ensure'  => 'present',
        'require' => 'Augeas[install module foo]'
      })}

      context 'with command set to /bin/true' do
        let(:params) do
          default_params.merge!({ :command => '/bin/true' })
        end
        
        context 'with augeasversion < "0.9.0"' do
          let(:facts) do { :augeasversion => '0.8.9' } end
          it { should contain_augeas('install module foo').with({
            'incl'    => 'modprobe.conf',
            'lens'    => 'Modprobe.lns',
            'changes' => "set install[. = 'foo'] 'foo /bin/true'",
            'onlyif'  => "match install[. = 'foo /bin/true'] size == 0",
            'require' => 'File[modprobe.conf]'
          }) }
        end

        context 'with augeasversion >= "0.9.0"' do
          let(:facts) do { :augeasversion => '0.9.0' } end
          it { should contain_augeas('install module foo').with({
            'incl'    => 'modprobe.conf',
            'lens'    => 'Modprobe.lns',
            'changes' => ["set install[. = 'foo'] foo","set install[. = 'foo']/command '/bin/true'"],
            'onlyif'  => "match install[. = 'foo'] size == 0",
            'require' => 'File[modprobe.conf]'
          }) }
        end
      end

      context 'without command set' do
        it { should contain_augeas('install module foo').with({
          'incl'    => 'modprobe.conf',
          'lens'    => 'Modprobe.lns',
          'changes' => "set install[. = 'foo'] foo",
          'onlyif'  => nil,
          'require' => 'File[modprobe.conf]'
          })}
      end
    end

    context "with ensure set to absent" do
      let(:params) do
        default_params.merge!( :ensure => 'absent' )
      end
      it { should contain_kmod__load('foo').with({ 'ensure' => 'absent'}) }
      it { should contain_augeas('remove module foo').with({
        'incl'    => 'modprobe.conf',
        'lens'    => 'Modprobe.lns',
        'changes' => "rm install[. = 'foo']",
        'onlyif'  => "match install[. = 'foo'] size > 0",
        'require' => 'File[modprobe.conf]'
      })}
    end
  end
end