require 'uri'

Puppet::Parser::Functions::newfunction(:uri_parse, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Returns information about an URI

    This function expects two arguments, an URI and the part of the URI you want to retrieve.

    Example:
    $uri = uri_parse($source_url)
    $source_filename = $uri['filename']

    Given an URL like: https://my_user:my_pass@www.example.com:8080/path/to/file.php?id=1&ret=0
    You obtain the following hash keys:
    scheme   : https
    userinfo : my_user:my_pass
    user     : my_user
    password : my_pass
    host     : www.example.com
    port     : 8080
    path     : /path/to/file.php
    query    : id=1&ret=0
    filename : file.php
    dirname  : /path/to
    extname  : php
    basename : file
  ENDHEREDOC
  raise ArgumentError, ("url_parse(): wrong number of arguments (#{args.count}; must be 1)") if args.count != 1
  uri = URI.parse(args[0])
  filename = File.basename(uri.path)
  extname = filename[/^.*(\.tar\.\w+)$/, 1] || File.extname(uri.path)
  {
    'scheme' => uri.scheme,
    'userinfo' => uri.userinfo,
    'user' => uri.user,
    'password' => uri.password,
    'host' => uri.host,
    'port' => uri.port,
    'path' => uri.path,
    'query' => uri.query,
    'filename' => filename,
    'dirname' => File.dirname(uri.path),
    'extname' => extname,
    'basename' => filename.chomp(extname)
  }
end
