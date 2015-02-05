Facter.add(:ipa_adminhomedir) do
  setcode do
    require 'etc'
    begin
      Etc.getpwnam('admin').dir
    rescue ArgumentError => ae
      ''
    end
  end
end
