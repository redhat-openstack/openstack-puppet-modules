# Fact: vtx
#
# Purpose:
#   Determine whether VT-X is enabled on the node.
#
# Resolution:
#   Checks for vmx (intel) or svm (amd) is part of /proc/cpuinfo flags
#
# Caveats:
#

# Author: Emilien Macchi <emilien.macchi@enovance.com>

Facter.add('vtx') do
  confine :kernel => :linux
  setcode do
    result = false
    begin
      # test on Intel and AMD plateforms
      if File.read('/proc/cpuinfo') =~ /(vmx|svm)/
        result = true
      end
    rescue
    end
    result
  end
end
