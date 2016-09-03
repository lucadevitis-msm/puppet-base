# Class: sensu_client
#
#
class base::sensu_client ($sensu_version,
                          $sensu_rpm_base_url,
                          $rabbitmq_host,
                          $rabbitmq_port = 5671,
                          $rabbitmq_user = "sensu",
                          $rabbitmq_password,
                          $rabbitmq_vhost = "/sensu",
                          $keepalive_handler = "decommission",
                          $plugin_source,
                          $subscriptions = ["default"],
                          $client_name = $::hostname) {

  # The call to `hiera_hash` bypass the hiera default lookup behaviour which
  # allows only the first value to be passed to the class. `hiera_hash`,
  # instead, merges all the values into a single hash allowing us to specify
  # `sensu_client::command_tokens` key in multiple files; that, in turn, allows
  # us to tweek some command options based on the environment (i.e. timeouts)
  $command_tokens = hiera_hash('sensu_client::command_tokens', {})

  $sensu_rpm = "${sensu_rpm_base_url}/sensu-${sensu_version}.x86_64.rpm"

  exec { "install_sensu":
    command => "/usr/bin/yum install -y ${sensu_rpm}",
    unless  => "/bin/rpm -qa | /bin/grep sensu",
  }

  file { "/etc/sensu/conf.d/client.json":
    ensure  => file,
    content => template("${name}/client.json.erb"),
    require => Exec["install_sensu"],
    notify  => Service["sensu-client"],
  }

  file { "/etc/sensu/config.json":
    ensure  => file,
    content => template("${name}/config.json.erb"),
    require => Exec["install_sensu"],
    notify  => Service["sensu-client"],
  }

  file { "/etc/sensu/conf.d/check-smoketest.json":
    ensure  => file,
    content => template("${name}/check-smoketest.json.erb"),
    require => Exec["install_sensu"],
    notify  => Service["sensu-client"],
  }

  file { "/etc/sensu/ssl":
    ensure  => directory,
    require => Exec["install_sensu"],
  }

  file { "/etc/sensu/ssl/client_cert.pem":
    ensure  => file,
    content => template("${name}/client_cert.pem.erb"),
    require => File["/etc/sensu/ssl"],
    notify  => Service["sensu-client"],
  }

  file { "/etc/sensu/ssl/client_key.pem":
    ensure  => file,
    content => template("${name}/client_key.pem.erb"),
    require => File["/etc/sensu/ssl"],
    notify  => Service["sensu-client"],
  }

  file { "/usr/local/bin/sync_sensu_plugins":
    ensure  => file,
    mode    => 700,
    content => template("${name}/sync_sensu_plugins.sh.erb"),
    notify  => Exec["sync_sensu_plugins"],
  }

  exec { "sync_sensu_plugins":
     command      => "/usr/local/bin/sync_sensu_plugins 1",
     path         => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
     environment  => ["HOME=/root"],
     refreshonly  => true,
  }

  exec { "install_sensu_plugin_gem":
    command     => "/usr/bin/gem install sensu-plugin --no-rdoc --no-ri",
    unless      => "/usr/bin/gem query --local | grep sensu-plugin",
    environment => ["HOME=/root"],
  }

  service { "sensu-client":
    enable  => true,
    ensure  => running,
    require => [ File["/etc/sensu/ssl/client_cert.pem", "/etc/sensu/ssl/client_key.pem", "/etc/sensu/config.json", "/etc/sensu/conf.d/client.json"], Exec["sync_sensu_plugins"] ],
  }

  file { "/etc/sudoers.d/sensu":
    ensure  => file,
    mode    => 0440,
    content => file("${name}/sodoers"),
  }

  cron { 'check_sensu_service':
    command => 'pgrep sensu-client || (rm -f /var/run/sensu/sensu-client.pid ; /etc/init.d/sensu-client start)',
    hour => '*',
    minute  => '*/5',
    require => Service["sensu-client"],
  }
}

