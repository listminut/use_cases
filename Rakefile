# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "simplecov"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]

namespace :coverage do
  desc "Collates all result sets generated by the different test runners"
  task :report do
    require "simplecov"

    SimpleCov.collate Dir["simplecov-resultset-*/.resultset.json"]
  end
end
