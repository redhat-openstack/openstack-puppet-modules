Puppet::Type.type(:mistral_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def self.file_path
    '/etc/mistral/mistral.conf'
  end

end
