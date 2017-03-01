require 'spec_helper'

describe 'nssdb::add_cert_and_key', :type => :define do
        let(:title) { 'qpidd' }
        let(:params) do {
            :nickname => 'Server-Cert',
            :cert     => '/tmp/server.cert',
            :key      => '/tmp/server.key',
            :basedir  => '/obsolete'
        }
        end

        context 'generate_pkcs12' do
            it{ should contain_exec('generate_pkcs12').with(
                :command   => %r{-in /tmp/server.cert -inkey /tmp/server.key.*file:/obsolete/qpidd.*out \'/obsolete/qpidd/qpidd.p12\' -name Server-Cert},
                :require   => [ 'File[/obsolete/qpidd/password.conf]',
                                'File[/obsolete/qpidd/cert8.db]',
                                'Package[openssl]' ],
                :subscribe => 'File[/obsolete/qpidd/password.conf]'
            )}
        end

        context 'load_pkcs12' do
            it{ should contain_exec('load_pkcs12').with(
                :command => %r{-i \'/obsolete/qpidd/qpidd.p12\' -d \'/obsolete/qpidd\' -w \'/obsolete/qpidd.*-k \'/obsolete/qpidd}
            )}
        end

end
