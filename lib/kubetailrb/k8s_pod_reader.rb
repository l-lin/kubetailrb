# frozen_string_literal: true

require_relative 'with_k8s_client'
require_relative 'validated'

module Kubetailrb
  # Read Kubernetes pod logs.
  class K8sPodReader
    include Validated
    include WithK8sClient

    attr_reader :pod_name, :opts

    def initialize(pod_name:, opts:, k8s_client: nil)
      validate(pod_name, opts)

      @k8s_client = k8s_client
      @pod_name = pod_name
      @opts = opts
    end

    def read
      pod_logs = k8s_client.get_pod_log(@pod_name, @opts.namespace, tail_lines: @opts.last_nb_lines)
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

      k8s_client.watch_pod_log(@pod_name, @opts.namespace) do |line|
        # NOTE: Is it good practice to update a variable that is outside of a
        # block? Can we do better?
        should_print_logs = true if line == first_log_to_display

        print_logs(line) if should_print_logs
      end
    end

    private

    def validate(pod_name, opts)
      raise_if_blank pod_name, 'Pod name not set.'

      raise InvalidArgumentError, 'Opts not set.' if opts.nil?
    end

    def print_logs(logs)
      if @opts.raw?
        puts logs
      elsif logs.to_s.include?("\n")
        logs.to_s.split("\n").each { |log| print_logs(log) }
      else
        puts "#{@pod_name} - #{logs}"
      end
    end
  end
end
