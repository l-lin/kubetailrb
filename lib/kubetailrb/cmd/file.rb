# frozen_string_literal: true

require 'kubetailrb/reader/file_reader'

module Kubetailrb
  module Cmd
    # Command to read a file.
    class File
      DEFAULT_NB_LINES = 10
      DEFAULT_FOLLOW = false
      FILE_FLAG = '--file'
      TAIL_FLAG = '--tail'
      attr_reader :reader

      def initialize(filepath:, last_nb_lines: DEFAULT_NB_LINES, follow: DEFAULT_FOLLOW)
        @reader = Kubetailrb::Reader::FileReader.new(filepath: filepath, last_nb_lines: last_nb_lines, follow: follow)
      end

      def execute
        @reader.read
      end

      class << self
        def create(*args)
          new(filepath: parse_filepath(*args), last_nb_lines: parse_nb_lines(*args), follow: parse_follow(*args))
        end

        def applicable?(*args)
          args.include?(FILE_FLAG)
        end

        private

        #
        # Parse the file path from arguments provided in the CLI, e.g.
        #
        #   kubetailrb --file /path/to/file
        #
        def parse_filepath(*args)
          index = args.find_index { |arg| arg == FILE_FLAG }.to_i

          raise MissingFileError, "Missing #{FILE_FLAG} value." if args[index + 1].nil?

          args[index + 1]
        end

        #
        # Parse nb lines from arguments provided in the CLI, e.g.
        #
        #   kubetailrb --file /path/to/file --tail 3
        #
        # will return 3.
        #
        # Will raise `MissingNbLinesValueError` if the value is not provided:
        #
        #   kubetailrb --file /path/to/file --tail
        #
        # Will raise `InvalidNbLinesValueError` if the provided value is not a
        # number:
        #
        #   kubetailrb --file /path/to/file --tail some-string
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

    class MissingFileError < RuntimeError
    end

    class InvalidNbLinesValueError < RuntimeError
    end
  end
end
