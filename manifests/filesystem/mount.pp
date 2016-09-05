define base::filesystem::mount ($mount_point         = $title,
                                $mount_device,
                                $mount_fstype        = 'ext4',
                                $mount_options       = 'defaults',
                                $owner               = 'root',
                                $group               = 'root',
                                $mode                = '0755',
                                $recurse_permissions = true)
{
  include wait_for
  include stdlib

  Exec {
    path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
  }

  validate_string($mount_point)
  validate_string($mount_device)
  validate_string($mount_fstype)
  validate_string($mount_options)
  validate_string($owner)
  validate_string($group)
  validate_string($mode)
  validate_bool($recurse_permissions)

  if $recurse_permissions {
    $chown_options = '-R'
  } else {
    $chown_options = ''
  }

  exec { 'mount_point_create':
    command => "install --directory ${mount_point}",
  }

  mount { $mount_point:
    ensure   => mounted,
    remounts => false,
    device   => $mount_device,
    fstype   => $mount_fstype,
    options  => $mount_options,
    require  => Exec['mount_point_create'],
  }

  wait_for { "filesystem_mounted":
    query             => "grep --quiet '^${mount_device} ${mount_point} ${mount_fstype}' < /proc/mount",
    exit_code         => 0,
    polling_frequency => 5,
    max_retries       => 64,
    require           => Mount[$mount_point],
  }

  exec { "mount_point_chmod":
    command => "chmod ${mode} ${mount_point}",
    require => Wait_for['filesystem_mounted']
  }
  exec { 'mount_point_chown':
    command => "chown ${chown_options} ${owner}:${group} ${mount_point}",
    unless   => "test \"$(stat --format='%u:%g' $mount_point)\" == '${owner}:${group}'",
    require => Wait_for['filesystem_mounted']
  }
}

