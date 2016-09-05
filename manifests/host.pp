class base::host ($block_devices = undef)
{
  include stdlib
  if $block_devices != undef {
      validate_hash($block_devices)
      create_resources('base::host::block_device', $block_devices)
  }
}
