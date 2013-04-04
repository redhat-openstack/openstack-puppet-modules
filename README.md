Puppet types for concatenating data via a template
==================================================

The `datacat` and `datacat_fragment` allow you to build up a data structure
which is rendered using a template.  This is similar to some of the common
concatenation patterns though it should be clearer.

[![Build Status](https://travis-ci.org/richardc/puppet-datacat.png)](https://travis-ci.org/richardc/puppet-datacat)

Sample Usage
------------

```puppet
datacat { '/etc/nagios/objects/hostgroups.cfg':
    template => "${module_name}/hostgroups.cfg.erb",
}

datacat_fragment { "${::fqdn} in device hostgroup":
    target => '/etc/nagios/objects/hostgroups.cfg',
    data   => {
        device => [ $::fqdn ],
    },
}

# fred.dc1.notreal has an ilo fred-ilo.dc1.notreal
$ilo_fqdn = regsubst($::fqdn, '\.', '-ilo.')
datacat_fragment { "${ilo_fqdn} in device hostgroup":
    target => '/etc/nagios/objects/hostgroups.cfg',
    data   => {
        device => [ $ilo_fqdn ],
    },
}
```

```erb
# hostgroups.cfg.erb
<% @data.keys.sort.each do |hostgroup| %>
define hostgroup {
    name <%= hostgroup %>
    members <%= @data[hostgroup].sort.join(',') %>
}
<% end %>
```

Will produce something like:

```
# /etc/nagios/objects/hostgroups.cfg
define hostgroup {
    name device
    members fred.dc1.notreal,fred-ilo.dc1.notreal
}
```


So the basic idea is like concat, only where concat's combining operation
is a simple concatenation of the fragments, the combining operation of a
datacat is to evaluate a template, which means multiple fragments can
appear in one line.



Copyright and License
---------------------

Copyright (C) 2013 Richard Clamp

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
