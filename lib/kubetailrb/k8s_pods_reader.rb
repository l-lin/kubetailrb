# frozen_string_literal: true

require_relative 'k8s_pod_reader'
require_relative 'with_k8s_client'

module Kubetailrb
  # Read multiple pod logs.
  class K8sPodsReader
    include Validated
    include WithK8sClient

    attr_reader :pod_query, :namespace, :last_nb_lines

    def initialize(pod_query:, namespace:, last_nb_lines:, follow:, k8s_client: nil)
      validate(pod_query, namespace, last_nb_lines, follow)

      @k8s_client = k8s_client
      @pod_query = Regexp.new(pod_query)
      @namespace = namespace
      @last_nb_lines = last_nb_lines
      @follow = follow
    end

    def read
      pods = find_pods

      threads = pods.map do |pod|
        # TODO: Use thread pool instead! Otherwise, with 1k+ pods, we might kill
        # our machine...
        Thread.new do
          K8sPodReader.new(
            k8s_client: k8s_client,
            pod_name: pod.metadata.name,
            namespace: @namespace,
            last_nb_lines: @last_nb_lines,
            follow: @follow
          ).read
        end
      end
      # NOTE: '&:' is a shorthand way of calling 'join' method on each thread.
      # It's equivalent to: threads.each { |thread| thread.join }
      threads.each(&:join)
    end

    def follow?
      @follow
    end

    private

    def validate(pod_query, namespace, last_nb_lines, follow)
      raise_if_blank pod_query, 'Pod query not set.'
      raise_if_blank namespace, 'Namespace not set.'
      validate_last_nb_lines last_nb_lines
      validate_follow follow
    end

    def find_pods
      k8s_client
        .get_pods(namespace: @namespace)
        .select { |pod| pod.metadata.name.match?(@pod_query) }
    end
  end
end
