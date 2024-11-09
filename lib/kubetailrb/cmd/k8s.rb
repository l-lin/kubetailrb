# frozen_string_literal: true

require 'kubetailrb/k8s_pod_reader'

module Kubetailrb
  module Cmd
    # Command to read k8s pod logs.
    class K8s
      DEFAULT_NB_LINES = 10
      DEFAULT_FOLLOW = false
      DEFAULT_NAMESPACE = 'default'
      NAMESPACE_FLAGS = %w[-n --namespace].freeze
      TAIL_FLAG = '--tail'
      attr_reader :reader

      def initialize(
        pod_name:,
        namespace: DEFAULT_NAMESPACE,
        last_nb_lines: DEFAULT_NB_LINES,
        follow: DEFAULT_FOLLOW
      )
        @reader = Kubetailrb::K8sPodReader.create(
          pod_name: pod_name,
          namespace: namespace,
          last_nb_lines: last_nb_lines,
          follow: follow
        )
      end

      def execute
        @reader.read
      end

      class << self
        def create(*args)
          new(
            pod_name: parse_pod_name(*args),
            namespace: parse_namespace(*args),
            last_nb_lines: parse_nb_lines(*args),
            follow: parse_follow(*args)
          )
        end

        def parse_pod_name(*args)
          # TODO: We could be smarter here? For example, if the pod names are
          # provided at the end of the command, like this:
          #   kubetailrb --tail 3 some-pod
          # The above command will not work because this method will return 3
          # instead of 'some-pod'...
          args.find { |arg| !arg.start_with? '-' }
        end

        #
        # Parse k8s namespace from arguments provided in the CLI, e.g.
        #
        #   kubetailrb some-pod -n sandbox
        #
        # will return 'sandbox'.
        #
        # Will raise `MissingNamespaceValueError` if the value is not provided:
        #
        #   kubetailrb some-pod -n
        #
        def parse_namespace(*args)
          return DEFAULT_NAMESPACE unless args.any? { |arg| NAMESPACE_FLAGS.include?(arg) }

          index = args.find_index { |arg| NAMESPACE_FLAGS.include?(arg) }.to_i

          raise MissingNamespaceValueError, "Missing #{NAMESPACE_FLAGS} value." if args[index + 1].nil?

          args[index + 1]
        end

        #
        # Parse nb lines from arguments provided in the CLI, e.g.
        #
        #   kubetailrb some-pod --tail 3
        #
        # will return 3.
        #
        # Will raise `MissingNbLinesValueError` if the value is not provided:
        #
        #   kubetailrb some-pod --tail
        #
        # Will raise `InvalidNbLinesValueError` if the provided value is not a
        # number:
        #
        #   kubetailrb some-pod --tail some-string
        #
        def parse_nb_lines(*args)
          return DEFAULT_NB_LINES unless args.include?(TAIL_FLAG)

          index = args.find_index { |arg| arg == TAIL_FLAG }.to_i

          raise MissingNbLinesValueError, "Missing #{TAIL_FLAG} value." if args[index + 1].nil?

          last_nb_lines = args[index + 1].to_i

          raise InvalidNbLinesValueError, "Invalid #{TAIL_FLAG} value: #{args[index + 1]}." if last_nb_lines.zero?

          last_nb_lines
        end

        def parse_follow(*args)
          flags = %w[-f --follow]

          return DEFAULT_FOLLOW unless args.any? { |arg| flags.include?(arg) }

          true
        end
      end
    end

    class MissingNbLinesValueError < RuntimeError
    end

    class MissingNamespaceValueError < RuntimeError
    end

    class InvalidNbLinesValueError < RuntimeError
    end
  end
end