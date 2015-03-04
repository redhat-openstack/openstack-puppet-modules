# example use of silent counter

include ::common::counter	# that's it!

# NOTE: we only see the notify message. no other exec/change is shown!
notify { 'counter':
        message => "Value is: ${::common_counter_simple}",
}

# vim: ts=8
