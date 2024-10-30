# frozen_string_literal: true

module Kubetailrb
  module Cmd
    # Display help.
    class Help
      def execute
        puts <<~HELP
          Tail your Kubernetes pod logs at the same time.

          Usage:
            kubetailrb pod-query [flags]

          Flags:
            -v, --version  Display version.
            -h, --help     Display help.
        HELP
      end
    end
  end
end
