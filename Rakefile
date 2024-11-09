# frozen_string_literal: true

require 'fileutils'

require 'bundler/gem_tasks'

require 'minitest/test_task'
Minitest::TestTask.create

require 'rubocop/rake_task'
RuboCop::RakeTask.new

require 'cucumber/rake/task'
Cucumber::Rake::Task.new

task default: %i[test cucumber rubocop]

namespace :test do
  desc 'Watch files and re-execute tests.'
  task :watch do
    exec('guard -c')
  end
end

K8S_NAMESPACE = 'sandbox'

namespace :k8s do
  desc 'Create local Kubernetes cluster.'
  task :create do
    next if k8s_up?

    puts 'Starting local Kubernetes cluster...'
    puts `k3d cluster create --config k3d/default.yml \
        --k3s-arg '--kubelet-arg=eviction-hard=imagefs.available<1%,nodefs.available<1%@agent:*' \
        --k3s-arg '--kubelet-arg=eviction-minimum-reclaim=imagefs.available=1%,nodefs.available=1%@agent:*';`

    puts "Creating namespace #{K8S_NAMESPACE}"
    `kubectl create namespace #{K8S_NAMESPACE}`
    `kubens #{K8S_NAMESPACE}`
  end

  desc 'Destroy local Kubernetes cluster.'
  task :nuke do
    next unless k8s_up?

    k3d_cluster = `k3d cluster list --no-headers`.split(' ').first
    puts "Destroying local Kubernetes cluster '#{k3d_cluster}'!!!"
    `k3d cluster delete #{k3d_cluster}`
  end

  desc 'Deploy application to k8s.'
  task :deploy, [:app_name] do |_, args|
    next unless k8s_up?

    app_name = args[:app_name]

    next if app_name.nil? || app_name.strip.empty?

    docker_image = "registry.localhost:5000/#{app_name}"
    clock_dir = "k3d/#{app_name}"

    puts "Building Docker image #{docker_image}"
    `docker build -t #{docker_image} #{clock_dir}`
    `docker push #{docker_image}`
    puts `kubectl delete po #{app_name} --force true` if pod_up?(app_name)
    puts `kubectl run #{app_name} --image #{docker_image}`
  end

  desc 'Deploy all applications to k8s.'
  task :deploy_all do
    Rake::Task['k8s:deploy'].invoke('clock')
    # Rake does not actually run the task, but rather it adds it to a task
    # queue. So we need to re-enable the task so it can be run again.
    Rake::Task['k8s:deploy'].reenable
    Rake::Task['k8s:deploy'].invoke('clock-json')
  end
end

def k8s_up?
  !`k3d cluster list --no-headers`.strip.empty?
end

def pod_up?(app_name)
  !`kubectl get po | grep '^#{app_name}'`.strip.empty?
end
