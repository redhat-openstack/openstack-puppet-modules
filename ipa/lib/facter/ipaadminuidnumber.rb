Facter.add("ipaadminuidnumber") do
  setcode do
    require 'etc'
    begin
      Etc.getpwnam('admin').uid
    rescue ArgumentError => ae
      ''
    end
  end
end
