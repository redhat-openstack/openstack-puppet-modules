require 'spec_helper'
describe 'cassandra::datastax_repo' do
  let(:pre_condition) { [
    'class apt () {}',
    'class apt::update () {}',
    'define apt::key ($id, $source) {}',
    'define apt::source ($location, $comment, $release, $include) {}',
  ] }

  context 'Regardless of which OS' do
    it { should compile }
    it { should contain_class('cassandra::datastax_repo') }
  end

  context 'On a RedHat OS with defaults for all parameters' do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    it { should contain_yumrepo('datastax') }
  end

  context 'On a Debian OS with defaults for all parameters' do
    let :facts do
      {
        :osfamily => 'Debian',
        :lsbdistid => 'Ubuntu',
        :lsbdistrelease => '14.04'
      }
    end

    it { should contain_class('apt') }
    it { should contain_class('apt::update') }
    it { is_expected.to contain_apt__key('datastaxkey') }
    it { is_expected.to contain_apt__source('datastax') }
    it { is_expected.to contain_exec('update-cassandra-repos') }
  end
end
