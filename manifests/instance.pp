# This class defines the base DWH instance.
class base::instance
{
  stage { 'swapfile': before   => Stage['system'] }
  stage { 'system': before     => Stage['main'] }
  stage { 'cleanup': require   => Stage['main'] }
  stage { 'smoketest': require => Stage['cleanup'] }
  stage { 'register': require  => Stage['smoketest'] }

  class { 'base::swapfile': stage  => 'swapfile' }
  class { 'base::system': stage    => 'system' }
  class { 'base::cleanup': stage   => 'cleanup' }
  class { 'base::smoketest': stage => 'smoketest' }
  class { 'base::register': stage  => 'register' }
}

