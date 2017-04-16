# XXX: demonstrate a huge bug in puppet/facter

require 'facter'

value = 'hello'
Facter.add('foo') do
	setcode {
		value
	}
end

thing = {}
thing['a'] = 'puppet'
thing['b'] = 'works'

thing.keys.each do |x|
	value = thing[x]
	Facter.add('foo_'+x) do
		setcode {
			value	# bork
			# Facter::Util::Resolution.exec("/bin/echo -n '"+value+"'")	# borks!
			# thing[x]	# works as expected
		}
	end
end

value = 'broken'	# shouldn't matter

