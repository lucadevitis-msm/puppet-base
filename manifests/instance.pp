# This class defines the base DWH instance.
class base::instance
{
  stage { 'system': before => Stage['main'] }
  stage { 'cleanup': after => Stage['main'] }

  class { 'base::system': stage  => 'system' }
  class { 'base::cleanup': stage => 'cleanup' }
}

