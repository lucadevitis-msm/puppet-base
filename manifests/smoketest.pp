# This class manages the installation of the smoketest. The smoketest is
# compiled from a template that *MUST* be created in the provisioning repo.
class base::smoketest($polling_frequency = 5, $max_retries = 40)
{
  include wait_for
  include stdlib

  validate_integer($polling_frequency)
  validate_integer($max_retries)

  file { '/opt/smoketest':
    ensure => directory,
  }

  file { '/opt/smoketest/check-smoketest.sh':
    ensure  => present,
    content => template("role/${::msmid_role}/check-smoketest.sh.erb"),
    require => File[ '/opt/smoketest' ]
  }

  wait_for { 'smoketest':
    query             => "/bin/bash /opt/smoketest/check-smoketest.sh",
    exit_code         => 0,
    polling_frequency => $polling_frequency,
    max_retries       => $max_retries,
    require           => File['/opt/smoketest/check-smoketest.sh']
  }
}
