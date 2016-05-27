require 'spec_helper'

describe 'pacemaker_cluster_options' do
  context 'interface' do
    it { is_expected.not_to eq(nil) }
    it { is_expected.to run.with_params.and_raise_error(ArgumentError) }
  end

  it { is_expected.to run.with_params(nil).and_return('') }

  it { is_expected.to run.with_params('test').and_return('test') }

  it { is_expected.to run.with_params(%w(--token 10000 --ipv6 --join 100)).and_return('--token 10000 --ipv6 --join 100') }

  it {
    hash = {
        '--token' => '10000',
        '--ipv6'  => true,
        '--join'  => '100',
        '--broadcast0' => false,
    }
    is_expected.to run.with_params(hash).and_return('--token 10000 --ipv6 --join 100')
  }

  it {
    hash = {
        'token' => '10000',
        'ipv6'  => true,
        'join'  => '100',
        'broadcast0' => false,
    }
    is_expected.to run.with_params(hash).and_return('--token 10000 --ipv6 --join 100')
  }
end
