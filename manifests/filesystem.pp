class base::filesystem ($mount_points = undef)
{
  include stdlib
  if $mount_points != undef {
    validate_hash($mount_points)
    create_resources('mount', $mount_points)
  }
}
