# frozen_string_literal: true

require_relative 'with_k8s_client'
require_relative 'validated'

module Kubetailrb
  # Read Kuberentes pod logs.
  class K8sPodReader
    include Validated
    include WithK8sClient

    attr_reader :pod_name, :namespace, :last_nb_lines

    def initialize(pod_name:, namespace:, last_nb_lines:, follow:, k8s_client: nil)
      @k8s_client = k8s_client
      @pod_name = pod_name
      @namespace = namespace
      @last_nb_lines = last_nb_lines
      @follow = follow

      validate
    end

    def read
      pod_logs = k8s_client.get_pod_log(@pod_name, @namespace, tail_lines: @last_nb_lines)
      unless follow?
        puts pod_logs
        return
      end

      # NOTE: The watch method from kubeclient does not accept `tail_lines`
      # argument, so I had to resort to some hack... by using the first log to
      # print out. Not ideal, since it's not really the N last nb lines, and
      # assume every logs are different, which may not be true.
      # But it does the job for most cases.
      first_log_to_display = pod_logs.to_s.split("\n").first
      print_logs = false

      k8s_client.watch_pod_log(@pod_name, @namespace) do |line|
        # NOTE: Is it good practice to update a variable that is outside of a
        # block? Can we do better?
        print_logs = true if line == first_log_to_display
        puts line if print_logs
      end
    end

    def follow?
      @follow
    end

    private

    def validate
      raise_if_blank @pod_name, 'Pod name not set.'
      raise_if_blank @namespace, 'Namespace not set.'
      validate_last_nb_lines @last_nb_lines
      validate_follow @follow
    end
  end
end
