class base::system
{
  require base::packages
  require base::python
  require base::java
  require base::cron
  require base::ife
  require base::smoketest

  require base::s3cmd
  require base::awscli
  require base::ec2_api_tools

  require timezone
  require cloudpassage
  require limits
  require sysctl
  require sensu_client
  require rsyslog::client

  # This let root properly run sudo with `-u` and `-g` flags, run `man sudo`.
  # That would let rightscripts like `generic.clone.and.run` to download a
  # script and properly run it as any user/group ather then root which is a
  # security improovement.

  file_line { 'sudo_root':
    path  => '/etc/sudoers',
    line  => 'root ALL=(ALL:ALL) ALL',
    match => '^root[[:space:]]+ALL.*'
  }

  # If s3fs is available before `base::mount`, we can delegate the bucket
  # mount.
  class { 'base::s3fs': } ->
  class { 'base::mount': } ->
  Class['base']
}
