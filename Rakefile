#!/usr/bin/env rake

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib/jmx_client/parser'
  t.test_files = FileList['spec/lib/jmx_client/*_spec.rb']
  t.verbose = true
end

task default: :test
