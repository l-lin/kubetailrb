# frozen_string_literal: true

require 'kubetailrb/validated'
require 'kubetailrb/filter/log_filter'
require 'kubetailrb/formatter/json_formatter'
require 'kubetailrb/formatter/no_op_formatter'
require 'kubetailrb/formatter/pod_metadata_formatter'
require_relative 'with_k8s_client'

module Kubetailrb
  module Reader
    # Read Kubernetes pod logs.
    class K8sPodReader
      include Validated
      include WithK8sClient

      attr_reader :pod_name, :opts

      def initialize(pod_name:, container_name:, opts:, k8s_client: nil)
        validate(pod_name, container_name, opts)

        @k8s_client = k8s_client
        @pod_name = pod_name
        @container_name = container_name
        @formatter = create_formatter(opts, pod_name, container_name)
        @filter = Kubetailrb::Filter::LogFilter.create(opts.exclude)
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

      def validate(pod_name, container_name, opts)
        raise_if_blank pod_name, 'Pod name not set.'
        raise_if_blank container_name, 'Container name not set.'
        raise_if_nil opts, 'Opts not set.'
      end

      def print_logs(logs)
        if logs.to_s.include?("\n")
          logs.to_s.split("\n").each { |log| print_logs(log) }
          return
        end

        puts @formatter.format(logs) if @filter.test(logs)
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

      def create_formatter(opts, pod_name, container_name)
        formatter = if opts.raw?
                      Kubetailrb::Formatter::NoOpFormatter.new
                    else
                      Kubetailrb::Formatter::JsonFormatter.new
                    end

        if opts.display_names?
          formatter = Kubetailrb::Formatter::PodMetadataFormatter.new(
            pod_name,
            container_name, formatter
          )
        end

        formatter
      end
    end

    class PodNotReadyError < RuntimeError
    end
  end
end
