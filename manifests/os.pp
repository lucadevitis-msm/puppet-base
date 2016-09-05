class base::os($packages = undef)
{
  require base::cron
  require base::pip
  require base::java
  require timezone
  require limits
  require sysctl

  # This let root properly run sudo with `-u` and `-g` flags, run `man sudo`.
  # That would let rightscripts like `generic.clone.and.run` to download a
  # script and properly run it as any user/group ather then root which is a
  # security improovement.

  file_line { 'sudo_root':
    path  => '/etc/sudoers',
    line  => 'root ALL=(ALL:ALL) ALL',
    match => '^root[[:space:]]+ALL.*'
  }

  if $packages != undef {
    validate_hash($packages)
    ensure_packages($packages)
  }
}
