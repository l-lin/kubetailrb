# frozen_string_literal: true

require 'kubetailrb/reader/k8s_pods_reader'

module Kubetailrb
  module Cmd
    # Command to read k8s pod logs.
    class K8s
      DEFAULT_NB_LINES = 10
      DEFAULT_NAMESPACE = 'default'
      DEFAULT_CONTAINER_QUERY = '.*'

      NAMESPACE_FLAGS = %w[-n --namespace].freeze
      TAIL_FLAG = '--tail'
      FOLLOW_FLAGS = %w[-f --follow].freeze
      RAW_FLAGS = %w[-r --raw].freeze
      DISPLAY_NAMES_FLAG = '--display-names'

      CONTAINER_FLAGS = %w[-c --container].freeze
      EXCLUDE_FLAGS = %w[-e --exclude].freeze

      attr_reader :reader

      def initialize(pod_query:, container_query:, opts:)
        @reader = Kubetailrb::Reader::K8sPodsReader.new(
          pod_query: pod_query,
          container_query: container_query,
          opts: opts
        )
      end

      def execute
        @reader.read
      end

      class << self
        def create(*args)
          new(
            pod_query: parse_pod_query(*args),
            container_query: parse_container_query(*args),
            opts: K8sOpts.new(
              namespace: parse_namespace(*args),
              last_nb_lines: parse_nb_lines(*args),
              follow: parse_follow(*args),
              raw: parse_raw(*args),
              display_names: parse_display_names(*args),
              exclude: parse_exclude(*args)
            )
          )
        end

        def parse_pod_query(*args)
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
          args.any? { |arg| FOLLOW_FLAGS.include?(arg) }
        end

        def parse_raw(*args)
          args.any? { |arg| RAW_FLAGS.include?(arg) }
        end

        def parse_container_query(*args)
          return DEFAULT_CONTAINER_QUERY unless args.any? { |arg| CONTAINER_FLAGS.include?(arg) }

          index = args.find_index { |arg| CONTAINER_FLAGS.include?(arg) }.to_i

          raise MissingContainerQueryValueError, "Missing #{CONTAINER_FLAGS} value." if args[index + 1].nil?

          args[index + 1]
        end

        def parse_display_names(*args)
          args.include?(DISPLAY_NAMES_FLAG)
        end

        #
        # Parse log exclusion from arguments provided in the CLI, e.g.
        #
        #   kubetailrb some-pod --exclude access-logs,dd-logs
        #
        # will return [access-logs, dd-logs].
        #
        # Will raise `MissingExcludeValueError` if the value is not provided:
        #
        #   kubetailrb some-pod --exclude
        #
        def parse_exclude(*args)
          return [] unless args.any? { |arg| EXCLUDE_FLAGS.include?(arg) }

          index = args.find_index { |arg| EXCLUDE_FLAGS.include?(arg) }.to_i

          raise MissingExcludeValueError, "Missing #{EXCLUDE_FLAGS} value." if args[index + 1].nil?

          args[index + 1].split(',')
        end
      end
    end

    class MissingNbLinesValueError < RuntimeError
    end

    class MissingNamespaceValueError < RuntimeError
    end

    class MissingContainerQueryValueError < RuntimeError
    end

    class MissingExcludeValueError < RuntimeError
    end

    class InvalidNbLinesValueError < RuntimeError
    end
  end
end
