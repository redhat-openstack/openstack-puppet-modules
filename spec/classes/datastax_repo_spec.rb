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
    it {
      should contain_class('cassandra::datastax_repo').only_with({
        'descr'   => 'DataStax Repo for Apache Cassandra',
        'key_id'  => '7E41C00F85BFC1706C4FFFB3350200F2B999A372',
        'key_url' => 'http://debian.datastax.com/debian/repo_key',
        'pkg_url' => nil,
        'release' => 'stable',
      })
    }
  end

  context 'On a RedHat OS with defaults for all parameters' do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    it {
      should contain_yumrepo('datastax').with({
        'ensure'   => 'present',
        'descr'    => 'DataStax Repo for Apache Cassandra',
        'baseurl'  => 'http://rpm.datastax.com/community',
        'enabled'  => 1,
        'gpgcheck' => 0
      })
    }
    it { should have_resource_count(1) }
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

    it {
      should contain_apt__key('datastaxkey').with({
        'id'     => '7E41C00F85BFC1706C4FFFB3350200F2B999A372',
        'source' => 'http://debian.datastax.com/debian/repo_key'
      })
    }

    it {
      should contain_apt__source('datastax').with({
        'location' => 'http://debian.datastax.com/community',
        'comment'  => 'DataStax Repo for Apache Cassandra',
        'release'  => 'stable'
      })
    }

    it { should contain_exec('update-cassandra-repos') }
    it { should have_resource_count(3) }
  end
end
