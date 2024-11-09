# frozen_string_literal: true

require_relative 'k8s_opts'
require_relative 'k8s_pod_reader'
require_relative 'with_k8s_client'

module Kubetailrb
  # Read multiple pod logs.
  class K8sPodsReader
    include Validated
    include WithK8sClient

    attr_reader :pod_query, :opts

    def initialize(pod_query:, formatter:, opts:, k8s_client: nil)
      validate(pod_query, formatter, opts)

      @k8s_client = k8s_client
      @pod_query = Regexp.new(pod_query)
      @formatter = formatter
      @opts = opts
    end

    def read
      pods = find_pods

      watch_for_new_pod_events

      threads = pods.map do |pod|
        # NOTE: How much memory does a Ruby Thread takes? Can we spawn hundreds
        # to thoudsands of Threads without issue?
        Thread.new do
          K8sPodReader.new(
            k8s_client: k8s_client,
            pod_name: pod.metadata.name,
            formatter: @formatter,
            opts: @opts
          ).read
        end
      end
      # NOTE: '&:' is a shorthand way of calling 'join' method on each thread.
      # It's equivalent to: threads.each { |thread| thread.join }
      threads.each(&:join)
    end

    private

    def validate(pod_query, formatter, opts)
      raise_if_blank pod_query, 'Pod query not set.'

      raise InvalidArgumentError, 'Formatter not set.' if formatter.nil?

      raise InvalidArgumentError, 'Opts not set.' if opts.nil?
    end

    def find_pods
      k8s_client
        .get_pods(namespace: @opts.namespace)
        .select { |pod| applicable?(pod) }
    end

    #
    # Watch any pod events, and if there's another pod that validates the pod
    # query, then let's read the pod logs!
    #
    def watch_for_new_pod_events
      k8s_client.watch_pods(namespace: @opts.namespace) do |notice|
        if new_pod_event?(notice) && applicable?(notice.object)
          Thread.new do
            K8sPodReader.new(
              k8s_client: k8s_client,
              pod_name: notice.object.metadata.name,
              formatter: @formatter,
              opts: @opts
            ).read
          end
        end
      end
    end

    def applicable?(pod)
      pod.metadata.name.match?(@pod_query)
    end

    def new_pod_event?(notice)
      notice.type == 'ADDED' && notice.object.kind == 'Pod'
    end
  end
end