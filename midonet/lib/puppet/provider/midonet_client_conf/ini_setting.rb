Puppet::Type.type(:midonet_client_conf).provide(
    :ini_setting,
    :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
) do

  def section
    resource[:name].split('/', 2).first
  end

  def setting
    resource[:name].split('/', 2).last
  end

  def setparator
    '='
  end

  def file_path
    '/root/.midonetrc'
  end
end
