# encoding: utf-8
require 'rubygems'
require 'bundler/setup'
require 'rake'
require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
end

task :default => :test

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "mongo_failover"
  gem.homepage = "http://github.com/moxiespaces/mongo_failover"
  gem.summary = %Q{Patch mongo ruby driver to handle failover events}
  gem.description = %Q{Patch mongo ruby driver to handle failover events via retry}
  gem.email = "kloeppingzd@gmail.com"
  gem.authors = ["Zachary Kloepping"]
  # dependencies defined in Gemfile
end


Rake::Task["release"].clear
desc "Release a gem to gemfury"
task :release => [:clean, :build] do
  version = File.read('VERSION')
  pkg_name = "mongo_failover-#{version}.gem"
  puts `fury push pkg/#{pkg_name}`
end