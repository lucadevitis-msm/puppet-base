class base::cleanup
{
  exec { 'swapoff':
    command => '/sbin/swapoff --ifexists /swapfile'
  }

  file { 'swapfile':
    ensure  => absent,
    require => Exec['swapoff']
  }

  # FIXME: cleanup devel packages
}
