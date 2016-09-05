define base::host::block_device ($device             = $title,
                                 $stripe_members     = undef,
                                 $fstype             = 'ext4',
                                 $mkfs               = true,
                                 $mkfs_timeout       = 5000,
                                 $blockdev_readahead = undef,
                                 $io_scheduler       = undef)
{
  include wait_for
  include stdlib

  Exec {
    path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
  }

  validate_absolute_path($device)
  validate_string($fstype)
  validate_bool($mkfs)

  if $fstype == undef or size($fstype) == 0 {
    fail('base::block_device::fstype is undef or empty')
  }


  if $stripe_members != undef {

    validate_array($stripe_members)

    $quoted_stripe_members = shellquote($stripe_members)
    $raid_devices = size($stripe_members)

    if $raid_devices == 0 {
      fail('base::block_device::stripe_members size is 0')
    }

    wait_for { 'stripe_members':
      query             => "lsblk ${quoted_stripe_members}",
      exit_code         => 0,
      polling_frequency => 5,
      max_retries       => 240
    }

    exec { 'stripe':
      command => "mdadm --create ${device} --level=stripe --raid-devices=${raid_devices} ${quoted_stripe_members}",
      unless  => "stat ${device}",
      require => Wait_for['stripe_members'],
      before  => Wait_for['device']
    }
  }

  wait_for { 'device':
    query             => "lsblk ${device}",
    exit_code         => 0,
    polling_frequency => 5,
    max_retries       => 240
  }

  if $mkfs == true {
    validate_integer($mkfs_timeout)

    exec { 'mkfs':
      command => "mkfs -t ${fstype} ${device}",
      timeout => $mkfs_timeout,
      unless  => "test \"$(blkid -o value -s TYPE ${device})\" == '${fstype}'",
      require => Wait_for['device'],
    }
  }

  if $blockdev_readahead != undef {
    validate_string($blockdev_readahead)

    exec { 'set_blockdev_readahead':
      command   => "blockdev --setra ${blockdev_readahead} ${device}",
      unless    => "blockdev --getra ${device} | grep ${blockdev_readahead}",
      require   => $mkfs ? {
        true    => Exec['mkfs'],
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
      require => Wait_for['device']
    }

    file_line {'set_io_scheduler_on_boot':
      path  => '/etc/rc.local',
      line  => "echo ${io_scheduler} > /sys/block/${device_basename}/queue/scheduler",
    }
  }
}
