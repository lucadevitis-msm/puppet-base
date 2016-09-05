class base::filesystem ($mount_points = undef)
{
  include stdlib
  require base::s3fs
  require base::host

  if $mount_points != undef {
    validate_hash($mount_points)
    create_resources('base::filesystem::mount', $mount_points)
  }
}
