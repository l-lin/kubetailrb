# frozen_string_literal: true

require "bundler/gem_tasks"

require "minitest/test_task"
Minitest::TestTask.create

require "rubocop/rake_task"
RuboCop::RakeTask.new

require "cucumber/rake/task"
Cucumber::Rake::Task.new

task default: %i[test cucumber rubocop]
