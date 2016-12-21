Facter.add(:lxc_version) do
  confine :kernel => :Linux
  setcode do
    version = Facter::Util::Resolution.exec('lxc --version')
    if version
      version.match(/\d+\.\d+\.\d+/).to_s
    else
      version = Facter::Util::Resolution.exec('lxc-console --version')
      version.match(/\d+\.\d+\.\d+/).to_s
    end
  end
end
