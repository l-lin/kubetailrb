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
                --tail     The number of lines from the end of the logs to show. Defaults to 10.
            -f, --follow   Output appended data as the file grows.
        HELP
      end
    end
  end
end
