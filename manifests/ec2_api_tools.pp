# This class manages the ec2 java tools. if `version` is provided the tools will
# be installed with the specified value.
#
# @param version The tools version string.
class base::ec2_api_tools ($version = undef)
{
  if $version != undef {
    require base::java

    validate_string($version)

    $ec2_api_tools_extract_path = '/opt/ec2'
    $ec2_api_tools_basename = "ec2-api-tools-${version}"
    $ec2_api_tools_filename = "${ec2_api_tools_basename}.zip"

    file { 'ec2_api_tools_extract_path': ensure => directory, path => $ec2_api_tools_extract_path }

    archive { 'ec2_api_tools':
      source_url   => "http://s3.amazonaws.com/ec2-downloads/${ec2_api_tools_filename}",
      destination  => "/tmp/${ec2_api_tools_filename}",
      cleanup      => true,
      extract      => true,
      extract_path => $ec2_api_tools_extract_path,
      creates      => "${ec2_api_tools_extract_path}/${ec2_api_tools_basename}",
      require      => File['ec2_api_tools_extract_path']
    }

    file { 'ec2_api_tools_bin':
      ensure => link,
      path   => "${ec2_api_tools_extract_path}/bin",
      target => "${ec2_api_tools_extract_path}/${ec2_api_tools_basename}/bin"
    }

    file { 'ec2_api_tools_lib':
      ensure => link,
      path   => "${ec2_api_tools_extract_path}/lib",
      target => "${ec2_api_tools_extract_path}/${ec2_api_tools_basename}/lib"
    }
  }
}
