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


    # hostgroups.cfg.erb
    <% @data.keys.sort.each do |hostgroup| %>
    define hostgroup {
        name <%= hostgroup %>
        members <%= @data[hostgroup].sort.join(',') %>
    }
    <% end %>


Will produce something like:

    # /etc/nagios/objects/hostgroups.cfg
    define hostgroup {
        name device
        members fred.dc1.notreal,fred-ilo.dc1.notreal
    }


So the basic idea is like concat, only where concat's combining operation
is a simple concatenation of the fragments, the combining operation of a
datacat is to evaluate a template, which means multiple fragments could
appear in one line.

I think an implementation approach that will work is to make each
datacat_fragment implicity depend on Datacat[self.target] somehow,
so that during evaluation the fragments populate the data field of the
datacat object, then the datacat object can fire up erb and then write
it down like a file resource (extra points if I can inherit from that
provider).  This means the template actually is evaluated on the agent,
which means we might need an option to capture the scope as part of the
datacat object to avoid alarm and confusion when the facts aren't present.

Bonus round:

    # No reason why the datacat_fragment can't load it's data_from a 
    # file on the agents disk
    datacat_fragment { "hostgroups from yaml file":
        target => '/etc/nagios/objects/hostgroups.cfg',
        data_from => '/etc/nagios/build/hostgroups.yaml',
    }
    
Leftover example

    datacat_fragment { "${::fqdn} in ${::domain} hostgroup":
        target => '/etc/nagios/objects/hostgroups.cfg',
        data   => {
            $::domain => [ $::fqdn ],
        },
    }
