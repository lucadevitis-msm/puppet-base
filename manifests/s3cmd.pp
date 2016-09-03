# This class manages the s3cmd python package, which provides the s3cmd command.
# if `version` is provided, s3cmd will be installed with the specified value.
#
# @param version The package version string.
class base::s3cmd ($version = undef)
{
  if $version != undef {
    require base::python

    validate_string($version)

    package { 's3cmd': ensure => $version, provider => 'pip' }
  }
}
