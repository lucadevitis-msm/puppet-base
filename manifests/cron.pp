# This class manages the `crond` configuration. if `jobs` is provided, cron
# jobs will be created.
#
# @param jobs The cron jobs to create.
class base::cron ($jobs = undef) {
  augeas { "disable-crond-emails":
    context => "/files/etc/sysconfig/crond",
    changes => 'set CRONDARGS \'"-m off"\'',
    notify  => Service["crond"],
  }
  service { 'crond': }

  if $jobs != undef {
    validate_hash($jobs)

    create_resources('cron', $jobs)
  }
}
