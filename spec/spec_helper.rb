require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |configure|
  configure.after(:suite) do
    RSpec::Puppet::Coverage.report! # (95)
  end
end
