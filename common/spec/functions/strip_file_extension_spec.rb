require 'spec_helper'

describe 'strip_file_extension' do

  describe 'strips file extensions' do

    it 'from single files' do
      should run.with_params('puppet.conf', 'conf').and_return('puppet')
    end

    it 'and removes full path' do
      should run.with_params('/etc/puppet/puppet.conf', 'conf').and_return('puppet')
    end
  end
end
