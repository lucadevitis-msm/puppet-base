define filesystem ($mount_point        = $title,
                   $device,
                   $stripe_members     = undef,
                   $fstype             = 'ext4',
                   $format             = true,
                   $format_timeout     = 5000,
                   $parent             = false,
                   $mount_options      = 'defaults',
                   $blockdev_readahead = undef,
                   $io_scheduler       = undef,
                   $owner              = 'root',
                   $group              = 'root',
                   $mode               = '0755',
                   $recursepermissions = true)
{
  include wait_for
  include stdlib

  Exec {
    path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
  }

  validate_string($mount_point)
  validate_string($device)
  validate_string($fstype)
  validate_bool($format)

  if $device == undef or size($device) == 0 {
    fail('base::filesystem::device is undef or empty')
  }

  if $mount_point == undef or size($mount_point) == 0 {
    fail('base::filesystem::mount_point is undef or empty')
  }

  if $fstype == undef or size($fstype) == 0 {
    fail('base::filesystem::fstype is undef or empty')
  }


  if $stripe_members != undef {

    validate_array($stripe_members)

    $stripe_members_string = shellquote($stripe_members)
    $raid_devices = size($stripe_members)

    if $raid_devices == 0 {
      fail('base::filesystem::stripe_members size is 0')
    }

    exec { 'stripe':
      command => "mdadm --create --verbose=${device} --level=stripe --raid-devices=${raid_devices} ${stripe_members_string}",
      unless  => "stat ${device}",
      before  => Wait_for['lsblk']
    }
  }

  wait_for { 'lsblk':
    query             => "lsbk ${device}",
    exit_code         => 0,
    polling_frequency => 5,
    max_retries       => 240
  }

  if $format == true {
    validate_integer($format_timeout)

    exec { 'format':
      command => "mkfs -t ${fstype} ${device}",
      timeout => $format_timeout,
      unless  => "test \"$(blkid -o value -s TYPE ${device})\" == '${fstype}'",
      require => Wait_for['lsblk'],
    }
  }

  if $blockdev_readahead != undef {
    validate_tring($blockdev_readahead)

    exec { 'set_blockdev_readahead':
      command   => "blockdev --setra ${blockdev_readahead} ${device}",
      unless    => "blockdev --getra ${device} | grep ${blockdev_readahead}",
      require   => $format ? {
        true    => Exec['format'],
        default => undef
      }
    }

    file_line {'set_blockdev_readahead_on_boot':
      path  => '/etc/rc.local',
      line  => "blockdev --setra ${blockdev_readahead} ${device}",
    }
  }

  if $io_scheduler != undef {
    validate_string($io_scheduler)

    $device_basename = basename($device)

    exec {'set_io_scheduler':
      command => "echo ${io_scheduler} > /sys/block/${device_basename}/queue/scheduler",
      unless  => "grep \"\\[${io_scheduler}\\]\" /sys/block/${device_basename}/queue/scheduler",
    }

    file_line {'set_io_scheduler_on_boot':
      path  => '/etc/rc.local',
      line  => "echo ${io_scheduler} > /sys/block/${device_basename}/queue/scheduler",
    }
  }

  # mount_point may be blank if we are setting up a stripe members with io_scheduler
  if $mount_point !=  {
    exec { 'mount_point':
      command => "install --directory --mode=${mode} --owner=${owner} --group=${group} ${mount_point}",
    }

    mount { $mount_point:
      ensure   => mounted,
      remounts => false,
      device   => $device,
      fstype   => $fstype,
      options  => $mount_options,
      require  => Exec['format', 'mount_point'],
    }

    wait_for { "check_mount_point":
      query             => "cut --fields=2 --delimiter=' ' < /proc/mounts | grep --quiet '^${mount_point}\$'",
      exit_code         => 0,
      polling_frequency => 5,
      max_retries       => 64,
      require           => Mount[$mount_point],
    }

    exec { "${device}_mode":
      command => "chmod ${mode} ${mount_point}",
      require => Wait_for['check_mount_point']
    }

    if $recursepermissions {
      $chownoption = '-R'
    } else {
      $chownoption = ''
    }
    exec { 'first_time_chown_of':
      command => "chown ${chownoption} ${owner}:${group} ${mount_point}",
      unless  => "ls -lad $mount_point | grep \"${owner} ${group}\"",
      require => Wait_for['check_mount_point']
    }
  }
}
