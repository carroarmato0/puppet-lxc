Facter.add(:lxc_version) do
  confine :kernel => :Linux
  setcode do
    if (Facter::Util::Resolution.which('lxc') || Facter::Util::Resolution.which('lxc-console'))
      lxc_version_command = Facter::Util::Resolution.which('lxc') ? 'lxc --version 2>&1' : 'lxc-console --version 2>&1'
      lxc_version = Facter::Util::Resolution.exec(lxc_version_command)
      lxc_version.match(/\d+\.\d+\.\d+/).to_s
    end
  end
end
