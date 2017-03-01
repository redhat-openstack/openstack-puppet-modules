require 'spec_helper'

describe 'nssdb::create', :type => :define do
    let(:title) { 'test' }
    let(:params) do {
        :owner_id   => 'nobody',
        :group_id   => 'nobody',
        :password   => 'secret',
        :basedir    => '/obsolete',
        :cacert     => '/ca.crt',
        :canickname => 'ca',
        :catrust    => 'CTu'
    }
    end

    context 'nssdb directory' do
        it{ should contain_file('/obsolete/test').with(
            :owner => 'nobody',
            :group => 'nobody'
        )}
    end

    context 'password file' do
        it{ should contain_file('/obsolete/test/password.conf').with(
            :owner   => 'nobody',
            :group   => 'nobody',
            :content => 'secret',
            :require => 'File[/obsolete/test]'
        )}
    end

    context 'database files' do
        databases = ['cert8.db', 'key3.db', 'secmod.db']
        databases.each do |db|
            it{ should contain_file('/obsolete/test/' + db).with(
                :owner   => 'nobody',
                :group   => 'nobody',
                :require => [ 'File[/obsolete/test/password.conf]', 'Exec[create_nss_db]']
            )}
        end
    end

    context 'create nss db' do
        it{ should contain_exec('create_nss_db').with(
            :command => %r{-d /obsolete/test -f /obsolete/test},
            :creates => [ '/obsolete/test/cert8.db', '/obsolete/test/key3.db', '/obsolete/test/secmod.db'],
            :require => [ 'File[/obsolete/test]',
                          'File[/obsolete/test/password.conf]',
                          'Package[nss-tools]' ]
        )}
    end

    context 'add ca cert' do
        it{ should contain_exec('add_ca_cert').with(
            :command => %r{-n ca -d /obsolete/test -t CTu.*-i /ca.crt},
            :onlyif  => %r{-e /ca.crt}
        )}
    end

end
