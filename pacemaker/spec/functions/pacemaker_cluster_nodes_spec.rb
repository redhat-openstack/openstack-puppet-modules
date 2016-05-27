require 'spec_helper'

describe 'pacemaker_cluster_nodes' do
  context 'interface' do
    it { is_expected.not_to eq(nil) }
    it { is_expected.to run.with_params.and_raise_error(ArgumentError) }
    it { is_expected.to run.with_params(1).and_raise_error(Puppet::Error, /Got unsupported nodes input data/) }
    it { is_expected.to run.with_params(nil).and_raise_error(Puppet::Error, /Nodes are not provided/) }
  end

  it 'can parse the input as a node list string' do
    input = 'n1 n2a,n2b n3, ,n4'
    hash = {
        "1"=>{"ring0"=>"n1", "id"=>"1"},
        "2"=>{"ring0"=>"n2a", "ring1"=>"n2b", "id"=>"2"},
        "3"=>{"ring0"=>"n3", "id"=>"3"},
        "4"=>{"ring1"=>"n4", "id"=>"4"},
    }
    array = %w(n1 n2a n2b n3 n4)
    list = 'n1 n2a,n2b n3 ,n4'
    is_expected.to run.with_params(input, 'hash').and_return(hash)
    is_expected.to run.with_params(input, 'array').and_return(array)
    is_expected.to run.with_params(input, 'list').and_return(list)
  end

  it 'can parse the input as an array of nodes' do
    input = ['n1', 'n2a,n2b', %w(n3a n3b), [nil, 'n4']]
    hash = {
        "1"=>{"ring0"=>"n1", "id"=>"1"},
        "2"=>{"ring0"=>"n2a", "ring1"=>"n2b", "id"=>"2"},
        "3"=>{"ring0"=>"n3a", "ring1"=>"n3b", "id"=>"3"},
        "4"=>{"ring1"=>"n4", "id"=>"4"},
    }
    array = %w(n1 n2a n2b n3a n3b n4)
    list = 'n1 n2a,n2b n3a,n3b ,n4'
    is_expected.to run.with_params(input, 'hash').and_return(hash)
    is_expected.to run.with_params(input, 'array').and_return(array)
    is_expected.to run.with_params(input, 'list').and_return(list)
  end

  it 'should parse the input as a hash structure' do
    input = {
        nil => {
            'vote' => '2',
            'ring0' => '192.168.0.1',
            'ring1' => '172.16.0.1',
        },
        1 => {
            'name' => 'n2',
            'ip' => '192.168.0.2',
            'ring1' => '172.16.0.2',
        },
        :a => {
            'name' => '192.168.0.3',
            'ring1' => '172.16.0.3',
        },
        '192.168.0.4' => {
            'ring1' => '172.16.0.4',
        },
        'node5' => {
            'id' => '10',
        },
    }
    hash = {
        "1"=>{"ring0"=>"192.168.0.1", "ring1"=>"172.16.0.1", "vote"=>"2", "id"=>"1"},
        "2"=>{"ring0"=>"192.168.0.2", "ring1"=>"172.16.0.2", "name"=>"n2", "id"=>"2"},
        "3"=>{"ring0"=>"192.168.0.3", "ring1"=>"172.16.0.3", "name"=>"192.168.0.3", "id"=>"3"},
        "4"=>{"ring0"=>"192.168.0.4", "ring1"=>"172.16.0.4", "name"=>"192.168.0.4", "id"=>"4"},
        "10"=>{"ring0"=>"node5", "name"=>"node5", "id"=>"10"},
    }
    array = %w(192.168.0.1 172.16.0.1 192.168.0.2 172.16.0.2 192.168.0.3 172.16.0.3 192.168.0.4 172.16.0.4 node5)
    list = '192.168.0.1,172.16.0.1 192.168.0.2,172.16.0.2 192.168.0.3,172.16.0.3 192.168.0.4,172.16.0.4 node5'
    is_expected.to run.with_params(input, 'hash').and_return(hash)
    is_expected.to run.with_params(input, 'array').and_return(array)
    is_expected.to run.with_params(input, 'list').and_return(list)
  end

  it 'should parse the input as a an array of hashes' do
    input = [
        {
            'vote' => '2',
            'ring0' => '192.168.0.1',
            'ring1' => '172.16.0.1',
        },
        {
            'name' => 'n2',
            'ip' => '192.168.0.2',
            'ring1' => '172.16.0.2',
        },
        {
            'name' => '192.168.0.3',
            'ring1' => '172.16.0.3',
        },
        {
            'ring1' => '172.16.0.4',
        },
        {
            'id' => '10',
            'ring0' => '192.168.0.5',
        },
        {
            'ring0' => '192.168.0.6',
        }
    ]
    hash = {
        "1"=>{"ring0"=>"192.168.0.1", "ring1"=>"172.16.0.1", "vote"=>"2", "id"=>"1"},
        "2"=>{"ring0"=>"192.168.0.2", "ring1"=>"172.16.0.2", "name"=>"n2", "id"=>"2"},
        "3"=>{"ring0"=>"192.168.0.3", "ring1"=>"172.16.0.3", "name"=>"192.168.0.3", "id"=>"3"},
        "4"=>{"ring1"=>"172.16.0.4", "id"=>"4"},
        "10"=>{"ring0"=>"192.168.0.5", "id"=>"10"},
        "5"=>{"ring0"=>"192.168.0.6", "id"=>"5"},
    }
    array = %w(192.168.0.1 172.16.0.1 192.168.0.2 172.16.0.2 192.168.0.3 172.16.0.3 172.16.0.4 192.168.0.5 192.168.0.6)
    list = '192.168.0.1,172.16.0.1 192.168.0.2,172.16.0.2 192.168.0.3,172.16.0.3 ,172.16.0.4 192.168.0.5 192.168.0.6'
    is_expected.to run.with_params(input, 'hash').and_return(hash)
    is_expected.to run.with_params(input, 'array').and_return(array)
    is_expected.to run.with_params(input, 'list').and_return(list)
  end

end
