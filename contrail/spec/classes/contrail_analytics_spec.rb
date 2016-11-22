#
# Copyright (C) 2016 Red Hat Inc. <licensing@redhat.com>
#
# Author: Alex Schultz <aschultz@redhat.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
require 'spec_helper'

describe 'contrail::analytics' do
  shared_examples 'contrail::analytics' do
    context 'with default paramters' do
      it { is_expected.to contain_class('contrail::analytics') }
      it { is_expected.to contain_anchor('contrail::analytics::start') }
      it { is_expected.to contain_class('contrail::analytics::install') }
      it { is_expected.to contain_class('contrail::analytics::config') }
      it { is_expected.to contain_class('contrail::analytics::service') }
      it { is_expected.to contain_anchor('contrail::analytics::end') }
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      it_behaves_like 'contrail::analytics'
    end
  end
end
