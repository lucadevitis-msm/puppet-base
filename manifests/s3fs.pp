# This class manages the installation of s3fs. If `version` and `source_url`
# are specified, the source will be downloaded, built and installed into the
# system.
#
# @param version         The s3fs version to use
# @param source_url      The s3fs source url
# @param accesskey       API accesskey
# @param secretaccesskey API secretaccesskey
class base::s3fs($version         = undef,
                 $source_url      = undef,
                 $accesskey       = undef,
                 $secretaccesskey = undef)
{

  if $version != undef {
    require base::fuse

    if $source_url == undef {
      fail('base::s3fs::source_url must be defined')
    }

    if $::base::fuse::version == undef {
      fail('base::fuse::version is undef, but s3fs will not work without fuse')
    }

    validate_string($version)
    validate_string($source_url)
    validate_string($accesskey)
    validate_string($secretaccesskey)

    $prefix = '/usr/local'
    $src = "${prefix}/src"

    $s3fs_basename = "s3fs-${version}"
    $s3fs_filename = "${s3fs_basename}.tar.gz"
    $s3fs_source   = "${src}/${s3fs_basename}"

    archive { 's3fs_source':
      source_url   => $source_url,
      destination  => "/tmp/${s3fs_filename}",
      cleanup      => true,
      extract      => true,
      extract_path => $src,
      creates      => "${s3fs_source}/autogen.sh",
    }
    exec { 's3fs_install':
      cwd         => $s3fs_source,
      path        => '/usr/bin:/bin:/usr/sbin:/sbin',
      environment => "PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib64/pkgconfig",
      command     => "${s3fs_source}/autogen.sh && ${s3fs_source}/configure --prefix=${prefix} && make && make install",
      unless      => "${prefix}/bin/s3fs --version | grep ${version}",
      require     => Archive['s3fs_source']
    }

    if $accesskey != undef and $secretaccesskey != undef {
      file { '/root/.passwd-s3fs':
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 600,
        content => "${accesskey}:${secretaccesskey}",
        require => Exec['s3fs_install']
      }
    } else {
      notice('base::s3fs: Skipping /root/.passwd-s3fs')
    }
  }
}
