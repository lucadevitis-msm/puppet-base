# This class manages the packages to be installed on the system.
# If `latest` is provided and is an hash, it will be used to install the latest
# version of packages on the system. If a `base::packages::devel` is provided
# in hiera, and it is an array, it will be used to install development
# packages. Multple values will be merged as per `hiera_array` function call.
#
# @param latest An hash of values to be used in ensure_packages.
class base::packages ($latest = undef)
{
  require stdlib

  $devel = hiera_array('base::packages::devel', undef)

  if $devel != undef {
    $defaults = { ensure => latest, require => Package[$devel] }
    ensure_packages($devel, { ensure => present })
  } else {
    $defaults = { ensure => latest }
  }

  if $latest != undef {
    validate_hash($latest)
    ensure_packages($latest, $defaults)
  }
}
