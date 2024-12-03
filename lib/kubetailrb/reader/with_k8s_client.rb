# frozen_string_literal: true

require 'kubeclient'

module Kubetailrb
  module Reader
    # Add behavior to get a k8s client by using composition.
    # NOTE: Is it the idiomatic way? Or shall I use a factory? Or is there a
    # better way?
    module WithK8sClient
      def k8s_client
        @k8s_client ||= create_k8s_client
      end

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
