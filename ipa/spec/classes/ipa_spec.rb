require 'spec_helper'

describe 'ipa', :type => :class do
  describe "on RedHat platform" do
    let(:facts) { { :osfamily => 'RedHat' } }

    context 'with master => true' do
      describe "ipa" do
        let(:params) {
          {
            :master  => true,
            :cleanup => false,
            :adminpw => '12345678',
            :dspw    => '12345678',
            :domain  => 'test.domain.org',
            :realm   => 'TEST.DOMAIN.ORG'
          }
        }
        it { should contain_class('ipa::master') }
        it { should contain_package('ipa-server') }
      end
    end
  end
end
