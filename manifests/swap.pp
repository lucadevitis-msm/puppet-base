class base::swap($size = undef)
{
  include stdlib

  if $size != undef {
    validate_integger($size)
      $count = $size * 1024

      exec { 'swapfile':
        command => "/bin/dd if=/dev/zero of=/swapfile bs=1024 count=${count}"
      }

      exec { 'mkswap':
        command => '/sbin/mkswap /swapfile',
        require => Exec['swapfile']
      }

      exec { 'swapon':
        command => '/sbin/swapon /swapfile',
        require => Exec['mkswap']
      }
  }
}
