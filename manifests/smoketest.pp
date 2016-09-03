# This class manages the installation of the smoketest. The smoketest is
# compiled from a template that *MUST* be created in the provisioning repo.
class base::smoketest
{
  file { "/opt/smoketest":
    ensure => directory,
  }

  file { "/opt/smoketest/check-smoketest.sh":
    ensure  => present,
    content => template("role/${::msmid_role}/check-smoketest.sh.erb"),
    require => File[ "/opt/smoketest" ]
  }
}
