Puppet::Type.type(:rhn_register).provide(:rhnreg_ks) do
  @doc = <<-EOS
    This provider registers a machine with RHN or a Satellite Server.
    If a machine is already registered it does nothing unless the force
    parameter is set to true.
  EOS

  confine :osfamily => :redhat

  commands :rhnreg_ks => "rhnreg_ks"

  def build_parameters
    params = []

    if @resource[:username].nil? and @resource[:activationkeys].nil?
        self.fail("Either an activation key or username/password is required to register")
    end

    params << "--profilename" << @resource[:profile_name] if ! @resource[:profile_name].nil?
    params << "--username" << @resource[:username] if ! @resource[:username].nil?
    params << "--password" << @resource[:password] if ! @resource[:password].nil?
    params << "--nohardware" if ! @resource[:hardware]
    params << "--nopackages" if ! @resource[:packages]
    params << "--novirtinfo" if ! @resource[:virtinfo]
    params << "--norhnsd" if ! @resource[:rhnsd]
    params << "--activationkey" <<  @resource[:activationkeys] if ! @resource[:activationkeys].nil?
    params << "--proxy" <<  @resource[:proxy] if ! @resource[:proxy].nil?
    params << "--proxyUser" << @resource[:proxy_user] if ! @resource[:proxy_user].nil?
    params << "--proxyPassword" << @resource[:proxy_password] if ! @resource[:proxy_password].nil?
    params << "--sslCACert" <<  @resource[:ssl_ca_cert] if ! @resource[:ssl_ca_cert].nil?
    params << "--serverUrl" << @resource[:server_url] if ! @resource[:server_url].nil?
    params << "--force" if @resource[:force]

    params.each do |pm|
      Puppet.debug("#{pm}")
    end

    return params
  end

  def register
    cmd = build_parameters
    rhnreg_ks(*cmd)
  end

  def create
    register
  end

  def destroy
    Puppet.debug("This server will be locally unregistered")
    FileUtils.rm_f("/etc/sysconfig/rhn/systemid")
  end

  def exists?
    Puppet.debug("Verifying if the server is already registered")
    if File.exists?("/etc/sysconfig/rhn/systemid")
      if @resource[:force] == true
        register
      end
      return true
    else
      return false
    end
  end

end

