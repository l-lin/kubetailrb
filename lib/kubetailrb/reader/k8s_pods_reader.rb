# frozen_string_literal: true

require 'kubetailrb/validated'
require 'kubetailrb/k8s_opts'
require_relative 'k8s_pod_reader'
require_relative 'with_k8s_client'

module Kubetailrb
  module Reader
    # Read multiple pod logs.
    class K8sPodsReader
      include Validated
      include WithK8sClient

      attr_reader :pod_query, :opts

      def initialize(pod_query:, opts:, k8s_client: nil)
        validate(pod_query, opts)

        @k8s_client = k8s_client
        @pod_query = Regexp.new(pod_query)
        @opts = opts
      end

      def read
        pods = find_pods
        watch_for_new_pod_events if @opts.follow?

        threads = pods.flat_map do |pod|
          pod.spec.containers.map do |container|
            # NOTE: How much memory does a Ruby Thread takes? Can we spawn hundreds
            # to thoudsands of Threads without issue?
            Thread.new { create_reader(pod.metadata.name, container.name).read }
          end
        end

        # NOTE: '&:' is a shorthand way of calling 'join' method on each thread.
        # It's equivalent to: threads.each { |thread| thread.join }
        threads.each(&:join)
      end

      private

      def validate(pod_query, opts)
        raise_if_blank pod_query, 'Pod query not set.'
        raise_if_nil opts, 'Opts not set.'
      end

      def find_pods
        k8s_client
          .get_pods(namespace: @opts.namespace)
          .select { |pod| applicable?(pod) }
      end

      def create_reader(pod_name, container_name)
        K8sPodReader.new(
          k8s_client: k8s_client,
          pod_name: pod_name,
          container_name: container_name,
          opts: @opts
        )
      end

      #
      # Watch any pod events, and if there's another pod that validates the pod
      # query, then let's read the pod logs!
      #
      def watch_for_new_pod_events
        k8s_client.watch_pods(namespace: @opts.namespace) do |notice|
          next unless applicable?(notice.object)

          on_new_pod_event notice if new_pod_event?(notice)
        end
      end

      def applicable?(pod)
        pod.metadata.name.match?(@pod_query)
      end

      def new_pod_event?(notice)
        notice.type == 'ADDED' && notice.object.kind == 'Pod'
      end

      def on_new_pod_event(notice)
        # NOTE: We are in another thread (are we?), so no sense to use
        # 'Thread.join' here.

        notice.object.spec.containers.map do |container|
          # NOTE: How much memory does a Ruby Thread takes? Can we spawn hundreds
          # to thoudsands of Threads without issue?
          puts "+ #{notice.object.metadata.name}/#{container.name}"
          Thread.new { create_reader(notice.object.metadata.name, container.name).read }
        end
      end
    end
  end
end
