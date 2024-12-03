# frozen_string_literal: true

require_relative 'with_k8s_client'
require_relative 'validated'
require_relative 'json_formatter'

module Kubetailrb
  # Read Kubernetes pod logs.
  class K8sPodReader
    include Validated
    include WithK8sClient

    attr_reader :pod_name, :opts

    def initialize(pod_name:, container_name:, formatter:, opts:, k8s_client: nil)
      validate(pod_name, container_name, formatter, opts)

      @k8s_client = k8s_client
      @pod_name = pod_name
      @container_name = container_name
      @formatter = formatter
      @opts = opts
    end

    def read
      pod_logs = read_pod_logs
      unless @opts.follow?
        print_logs pod_logs
        return
      end

      # NOTE: The watch method from kubeclient does not accept `tail_lines`
      # argument, so I had to resort to some hack... by using the first log to
      # print out. Not ideal, since it's not really the N last nb lines, and
      # assume every logs are different, which may not be true.
      # But it does the job for most cases.
      first_log_to_display = pod_logs.to_s.split("\n").first
      should_print_logs = false

      k8s_client.watch_pod_log(@pod_name, @opts.namespace, container: @container_name) do |line|
        # NOTE: Is it good practice to update a variable that is outside of a
        # block? Can we do better?
        should_print_logs = true if line == first_log_to_display

        print_logs(line) if should_print_logs
      end
    end

    private

    def validate(pod_name, container_name, formatter, opts)
      raise_if_blank pod_name, 'Pod name not set.'
      raise_if_blank container_name, 'Container name not set.'

      raise ArgumentError, 'Formatter not set.' if formatter.nil?

      raise ArgumentError, 'Opts not set.' if opts.nil?
    end

    def print_logs(logs)
      if logs.to_s.include?("\n")
        logs.to_s.split("\n").each { |log| print_logs(log) }
        return
      end

      if @opts.raw?
        puts @formatter.format(logs)
      else
        puts "#{@pod_name} #{@container_name} - #{@formatter.format logs}"
      end
      $stdout.flush
    end

    def read_pod_logs
      # The pod may still not up/ready, so small hack to retry 120 times (number
      # taken randomly) until the pod returns its logs.
      120.times do
        pod_logs = k8s_client.get_pod_log(
          @pod_name,
          @opts.namespace,
          container: @container_name,
          tail_lines: @opts.last_nb_lines
        )

        if pod_logs.to_s.split("\n").empty?
          raise PodNotReadyError, "No log returned from #{@pod_name}/#{@container_name}"
        end

        return pod_logs
      rescue Kubeclient::HttpError, PodNotReadyError => e
        puts e.message
        sleep 1
      end
    end
  end

  class PodNotReadyError < RuntimeError
  end
end
