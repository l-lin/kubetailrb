# frozen_string_literal: true

require 'kubetailrb/file_reader'

module Kubetailrb
  module Cmd
    # Command to read a file.
    class File
      DEFAULT_NB_LINES = 10
      DEFAULT_FOLLOW = false
      attr_reader :reader

      def initialize(filepath:, last_nb_lines: 10, follow: false)
        @reader = Kubetailrb::FileReader.new(filepath: filepath, last_nb_lines: last_nb_lines, follow: follow)
      end

      def execute
        @reader.read
      end

      class << self
        def create(*args)
          new(filepath: parse_filepath(*args), last_nb_lines: parse_nb_lines(*args))
        end

        private

        def contains_flags?(*args)
          args.any? { |arg| flags.include?(arg) }
        end

        #
        # The filepath is provided directly as an argument, so not as a flag. The
        # implementation is really simple and does not cover filepath that begins
        # with a `-`.
        #
        def parse_filepath(*args)
          args.find { |arg| !arg.start_with? '-' }
        end

        #
        # Parse nb lines from arguments provided in the CLI, e.g.
        #
        #   kubetailrb /path/to/file -n 3
        #
        # will return 3.
        #
        # Will raise `MissingNbLinesValueError` if the value is not provided:
        #
        #   kubetailrb /path/to/file -n
        #
        # Will raise `InvalidNbLinesValueError` if the provided value is not a
        # number:
        #
        #   kubetailrb /path/to/file -n some-string
        #
        def parse_nb_lines(*args)
          flag = '--tail'

          return DEFAULT_NB_LINES unless args.include?(flag)

          index = args.find_index { |arg| flag == arg }.to_i

          raise MissingNbLinesValueError, 'Missing --tail value.' if args[index + 1].nil?

          last_nb_lines = args[index + 1].to_i

          raise InvalidNbLinesValueError, "Invalid --tail value: #{args[index + 1]}." if last_nb_lines.zero?

          last_nb_lines
        end

        def parse_follow
          flags = %w[-f --follow]

          DEFAULT_FOLLOW unless contains_flags?(flags)
        end
      end
    end

    class MissingNbLinesValueError < RuntimeError
    end

    class InvalidNbLinesValueError < RuntimeError
    end
  end
end
