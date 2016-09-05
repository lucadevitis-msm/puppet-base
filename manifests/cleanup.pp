class base::cleanup
{
  exec { 'swapoff':
    command => '/sbin/swapoff /swapfile',
    onlyif  => '/usr/bin/test -f /swapfile'
  }

  file { 'swapfile':
    ensure  => absent,
    require => Exec['swapoff']
  }

  # FIXME: cleanup devel packages
}
