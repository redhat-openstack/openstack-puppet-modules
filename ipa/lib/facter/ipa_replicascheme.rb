Facter.add(:ipa_replicascheme, :timeout => 10) do
  setcode do
    host = Facter.value(:hostname)
    domain = Facter.value(:domain)
    if File.exists?('/etc/ipa/primary') and File.exist?(File.expand_path('~admin')) and File.exists?(File.expand_path('~admin/admin.keytab'))
      if host and domain
        fqdn = [host, domain].join(".")
      end    
    servers = Facter::Util::Resolution.exec("/sbin/runuser -l admin -c '/usr/sbin/ipa-replica-manage list' 2>/dev/null | /bin/egrep -v '#{fqdn}|winsync' | /bin/cut -d: -f1")
    combinations = servers.scan(/[\w.-]+/).combination(2).to_a
    combinations.collect { |combination| combination.join(',') }.join(':')
    else   
      nil    
    end    
  end    
end
