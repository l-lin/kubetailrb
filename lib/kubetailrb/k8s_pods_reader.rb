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

    def initialize(pod_query:, opts:, k8s_client: nil)
      validate(pod_query, opts)

      @k8s_client = k8s_client
      @pod_query = Regexp.new(pod_query)
      @opts = opts
    end

    def read
      pods = find_pods

      threads = pods.map do |pod|
        Thread.new do
          K8sPodReader.new(
            k8s_client: k8s_client,
            pod_name: pod.metadata.name,
            opts: @opts
          ).read
        end
      end
      # NOTE: '&:' is a shorthand way of calling 'join' method on each thread.
      # It's equivalent to: threads.each { |thread| thread.join }
      threads.each(&:join)
    end

    private

    def validate(pod_query, opts)
      raise_if_blank pod_query, 'Pod query not set.'

      raise InvalidArgumentError, 'Opts not set.' if opts.nil?
    end

    def find_pods
      k8s_client
        .get_pods(namespace: @opts.namespace)
        .select { |pod| pod.metadata.name.match?(@pod_query) }
    end
  end
end
