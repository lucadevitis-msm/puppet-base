# This class manages the awscli python package, which provides the aws command.
# if `version` is provided, awscli will be installed with the specified value.
#
# @param version The package version string.
class base::awscli ($version = undef)
{
  if $version != undef {
    require base::python

    validate_string($version)

    package { 'awscli': ensure => $version, provider => 'pip' }
  }
}
