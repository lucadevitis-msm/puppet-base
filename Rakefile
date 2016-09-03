require 'puppetlabs_spec_helper/rake_tasks'
# require 'puppet_x/puppetlabs/strings/util'
require 'rake/clean'
# require 'rubocop/rake_task'

# Tells which files to remove on clean task.
CLEAN.include(['.yardoc', 'doc', 'strings.json', 'coverage'])

# `:default` task require `:help`. Not necessary.
Rake.application['default'].prerequisites.delete('help')

# Create `:rubocop` task
# RuboCop::RakeTask.new :rubocop do |config|
#   config.options = %w(--debug)
#   config.patterns = %w(Rakefile)
# end

# desc 'Generate Puppet documentation with YARD.'
# task :strings do
#   PuppetX::PuppetLabs::Strings::Util.generate
# end

# Let's create a few requirements.
# task default: [:strings, :spec]
# task spec: [:spec_prep, :validate]
# task spec: [:lint]
# task validate: [:rubocop, :lint]
# task clean: [:spec_clean]
