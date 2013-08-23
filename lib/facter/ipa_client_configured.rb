Facter.add("ipa_client_configured") do
  setcode do
    if File.exist? "/etc/ipa/default.conf"
      "true"
    else
      "false"
    end
  end
end
