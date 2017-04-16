# this is just a proof of concept example, to help you visualize how this works

include common::again

# when notified, this timer will run puppet again, delta seconds after it ends!
common::again::delta { 'delta-timer':
	delta => 120,	# 2 minutes
	#start_timer_now => true,	# use this to start the countdown asap!
}

file { '/tmp/foo':
	content => "Something happened!\n",
	# NOTE: that as long as you don't remove or change the /tmp/foo file,
	# this will only cause a notify when the file needs changes done. This
	# is what prevents this from infinite recursion, and lets puppet sleep.
	notify => Common::Again::Delta['delta-timer'],	# notify puppet!
}

# always exec so that i can easily see when puppet runs... proof that it works!
exec { 'proof':
	command => '/bin/date >> /tmp/puppet.again',
}

