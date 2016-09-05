class base::system
{
  require base::host
  require base::os
  require base::filesystem

  require base::ife
  # require base::totskey

  require base::ec2_api_tools

  require cloudpassage
  require sensu_client
  require rsyslog::client
}
