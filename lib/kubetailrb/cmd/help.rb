# frozen_string_literal: true

module Kubetailrb
  module Cmd
    # Display help.
    class Help
      FLAGS = %w[-h --help].freeze

      def execute
        puts <<~HELP
          Tail your Kubernetes pod logs at the same time.

          Usage:
            kubetailrb pod-query [flags]

          Flags:
            -v, --version   Display version.
            -h, --help      Display help.
                --tail      The number of lines from the end of the logs to show. Defaults to 10.
            -f, --follow    Output appended data as the file grows.
                --file      Display file content.
            -r, --raw       Only display pod logs, without any special formatting.
                --verbose   Display pod and container names.
            -n, --namespace Kubernetes namespace to use.
            -c, --container Container name when multiple containers in pod. Default to '.'.
        HELP
      end

      class << self
        def applicable?(*args)
          missing_args?(*args) || contains_flags?(*args)
        end

        private

        def missing_args?(*args)
          args.nil? || args.empty?
        end

        def contains_flags?(*args)
          args.any? { |arg| FLAGS.include?(arg) }
        end
      end
    end
  end
end
