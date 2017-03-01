# this is just a proof of concept example, to help you visualize how this works

include common::again

file { '/tmp/foo':
	content => "Something happened!\n",
	# NOTE: that as long as you don't remove or change the /tmp/foo file,
	# this will only cause a notify when the file needs changes done. This
	# is what prevents this from infinite recursion, and lets puppet sleep.
	notify => Exec['again'],	# notify puppet!
}

# always exec so that i can easily see when puppet runs... proof that it works!
exec { 'proof':
	command => '/bin/date >> /tmp/puppet.again',
}

