# frozen_string_literal: true

require 'kubeclient'

module Kubetailrb
  # Read Kuberentes pod logs.
  class K8sPodReader
    attr_reader :pod_name, :namespace, :last_nb_lines

    def initialize(k8s_client:, pod_name:, namespace:, last_nb_lines:, follow:)
      @k8s_client = k8s_client
      @pod_name = pod_name
      @namespace = namespace
      @last_nb_lines = last_nb_lines
      @follow = follow

      validate
    end

    def read
      @k8s_client = create_k8s_client if @k8s_client.nil?

      if follow?
        # TODO: take into account last nb line!
        @k8s_client.watch_pod_log(@pod_name, @namespace) do |line|
          puts line
        end
      else
        puts @k8s_client.get_pod_log(@pod_name, @namespace, tail_lines: @last_nb_lines)
      end
    end

    def follow?
      @follow
    end

    private

    def validate
      raise InvalidArgumentError, 'K8s client not set.' if @k8s_client.nil?

      raise_if_blank @pod_name, 'Pod name not set.'

      raise_if_blank @namespace, 'Namespace not set.'

      last_nb_lines_valid = @last_nb_lines.is_a?(Integer) && @last_nb_lines.positive?

      raise InvalidArgumentError, "Invalid last_nb_lines: #{@last_nb_lines}." unless last_nb_lines_valid

      raise InvalidArgumentError, "Invalid follow: #{@follow}." unless @follow.is_a?(Boolean)
    end

    def raise_if_blank(arg, error_message)
      raise InvalidArgumentError, error_message if arg.nil? || arg.strip&.empty?
    end

    class << self
      def create(pod_name:, namespace:, last_nb_lines:, follow:)
        new(
          k8s_client: create_k8s_client,
          pod_name: pod_name,
          namespace: namespace,
          last_nb_lines: last_nb_lines,
          follow: follow
        )
      end

      private

      def create_k8s_client
        config = Kubeclient::Config.read(ENV['KUBECONFIG'] || "#{ENV["HOME"]}/.kube/config")
        context = config.context
        Kubeclient::Client.new(
          context.api_endpoint,
          'v1',
          ssl_options: context.ssl_options,
          auth_options: context.auth_options
        )
      end
    end
  end
end
