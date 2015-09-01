Puppet::Type.type(:gnocchi_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def self.file_path
    '/etc/gnocchi/gnocchi.conf'
  end

end
