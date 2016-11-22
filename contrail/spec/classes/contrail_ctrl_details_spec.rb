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

describe 'contrail::ctrl_details' do
  shared_examples 'contrail::ctrl_details' do
    context 'with default parameters' do
      it { is_expected.to contain_class('contrail::ctrl_details') }
      it { is_expected.to contain_file('/etc/contrail/ctrl-details').with(
        :ensure => 'file').with_content("SERVICE_TOKEN=
AUTH_PROTOCOL=http
ADMIN_TOKEN=password
CONTROLLER=127.0.0.1
AMQP_SERVER=127.0.0.1
COMPUTE=127.0.0.1
CONTROLLER_MGMT=127.0.0.1
INTERNAL_VIP=127.0.0.1
CONTRAIL_INTERNAL_VIP=127.0.0.1
EXTERNAL_VIP=127.0.0.1
")
      }
    end
  end

  on_supported_os.each do |os, facts|
    it_behaves_like 'contrail::ctrl_details'
  end
end
