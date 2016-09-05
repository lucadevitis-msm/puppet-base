# This class manages the installation of PIP as both a command and as a puppet
# package provider.
class base::pip
{
  $get_pip_py = '/usr/local/bin/get-pip.py'
  $get_pip_url = "https://bootstrap.pypa.io/get-pip.py"
  $pip = '/usr/bin/pip'

  exec { 'get_pip_py_wget':
    command => "/usr/bin/wget --output-document=- --quiet ${get_pip_url} > ${get_pip_py}",
    creates => $get_pip_py,
    unless  => "/usr/bin/test -e ${pip}"
  }

  exec { 'get_pip_py_run':
    command => "/usr/bin/python ${get_pip_py}",
    creates => $pip,
    require => Exec['get_pip_py_wget']
  }

  file { '/usr/bin/pip-python'
    ensure  => 'link',
    target  => $pip,
    require => Exec['pip']
  }
}
