# This class manages fuse. if `version` is provided, fuse will be installed
# with the specified value.
#
# @param version    The fuse version string.
# @param source_url The source url.
class base::fuse($version = undef, $source_url = undef)
{
  if $version != undef {
    require base::packages

    if $source_url == undef {
      fail('base::fuse::source_url must be defined')
    }

    validate_string($version)
    validate_string($source_url)

    $prefix = '/usr/local'
    $src = "${prefix}/src"

    $fuse_basename = "fuse-${version}"
    $fuse_filename = "${fuse_basename}.tar.gz"
    $fuse_source   = "${src}/${fuse_basename}"

    archive { 'fuse_source':
      source_url   => $source_url,
      destination  => "/tmp/${fuse_filename}",
      cleanup      => true,
      extract      => true,
      extract_path => $src,
      creates      => "${fuse_source}/configure",
    }
    exec { 'fuse_install':
      cwd     => $fuse_source,
      path    => '/usr/bin:/bin:/usr/sbin:/sbin',
      command => "${fuse_source}/configure --prefix=${prefix} && make && make install",
      unless  => "${prefix}/bin/fusermount -V | grep ${version}"
      require => Archive['fuse_source']
    }
  }
}
