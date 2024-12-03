# frozen_string_literal: true

require 'kubetailrb/validated'

module Kubetailrb
  module Formatter
    # Display the pod and container name.
    class PodMetadataFormatter
      include Validated

      def initialize(pod_name, container_name, formatter)
        @pod_name = pod_name
        @container_name = container_name
        @formatter = formatter

        validate
      end

      def format(log)
        "#{@pod_name}/#{@container_name} | #{@formatter.format(log)}"
      end

      private

      def validate
        raise_if_blank @pod_name, 'Pod name not set.'
        raise_if_blank @container_name, 'Container name not set.'
        raise_if_nil @formatter, 'Formatter not set.'
      end
    end
  end
end
