class base::mount ($devices = undef)
{

  if $devices != undef {
    validate_hash($devices)
    create_resources('mount_device', $devices)
  }
}
