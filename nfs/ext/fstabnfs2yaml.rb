# ruby script to turn /etc/fstab into YAML for Hiera for all NFS entries
#
# Garrett Honeycutt - copyright 2013 - code@garretthoneycutt.com
#
# License: Apache Software License v2.0
#
puts 'nfs::mounts:'
f = File.open('/etc/fstab','r')
f.each do |line|
  linearray = Array.new
  if line[0] != '#'
    line.split(/\s+/).each do |word|
     linearray << word
    end
     device = linearray[0]
     mount = linearray[1]
     fstype = linearray[2]
     options = linearray[3]
     if fstype == 'nfs'
       puts "  #{mount}:\n    ensure: present\n    device: #{device}\n    options: #{options}\n    fstype: nfs"
     end
  end
end
