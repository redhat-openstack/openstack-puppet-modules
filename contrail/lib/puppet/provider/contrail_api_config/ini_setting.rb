Puppet::Type.type(:contrail_api_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
) do

  # the setting is always default
  # this if for backwards compat with the old puppet providers
  # for contrail_api_config
  def section
    resource[:name].split('/', 2).first
  end

  # assumes that the name was the setting
  # this is to maintain backwards compat with the the older
  # stuff
  def setting
    resource[:name].split('/', 2).last
  end

  def separator
    '='
  end

  def self.file_path
    '/etc/contrail/contrail-api.conf'
  end

  # added for backwards compatibility with older versions
  # of inifile
  def file_path
    self.class.file_path
  end

end
