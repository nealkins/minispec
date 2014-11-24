require 'rake'
require 'rake/testtask'
require 'bundler/gem_tasks'

root = File.expand_path('..', __FILE__)
Rake::TestTask.new do |t|
  t.ruby_opts << '-r "%s/test/setup" -I "%s/lib"' % [root, root]
  t.pattern = 'test/**/test__*.rb'
  t.verbose = true
end
task default: :test
