#    Copyright 2015 Midokura SARL, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
require 'logger'

module Puppet::Parser::Functions
  newfunction(:zookeeper_servers, :type => :rvalue
  ) do |argv|

    servers = argv[0]
    if servers.class == Hash
      servers = Array.new(1, servers)
    end
    servers = servers.sort_by{|server| server['id']}
    return servers.map { |hash| hash['host'] }
  end

end
