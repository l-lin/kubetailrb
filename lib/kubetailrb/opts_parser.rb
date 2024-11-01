# frozen_string_literal: true

module Kubetailrb
  # Parse CLI arguments and flags.
  # NOTE: We could use the standard library optparse (OptionParser) or a more
  # comprehensive tool like Thor to achieve this, but that would defeat the
  # purpose of learning by implementing it ourselves.
  class OptsParser
    def initialize(*args)
      @args = *args
    end

    def parse
      return Cmd::Help.new if missing_args? || contains_flags?(%w[-h --help])

      return Cmd::Version.new if contains_flags?(%w[-v --version])

      Cmd::File.new(filepath: parse_filepath, last_nb_lines: parse_nb_lines)
    end

    private

    DEFAULT_NB_LINES = 10

    def missing_args?
      @args.nil? || @args.empty?
    end

    def contains_flags?(flags)
      @args.any? { |arg| flags.include?(arg) }
    end

    #
    # The filepath is provided directly as an argument, so not as a flag. The
    # implementation is really simple and does not cover filepath that begins
    # with a `-`.
    #
    def parse_filepath
      @args.find { |arg| !arg.start_with? '-' }
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
    def parse_nb_lines
      flag = '--tail'

      return DEFAULT_NB_LINES unless @args.include?(flag)

      index = @args.find_index { |arg| flag == arg }.to_i

      raise MissingNbLinesValueError, 'Missing --tail value.' if @args[index + 1].nil?

      last_nb_lines = @args[index + 1].to_i

      raise InvalidNbLinesValueError, "Invalid --tail value: #{@args[index + 1]}." if last_nb_lines.zero?

      last_nb_lines
    end
  end

  class MissingNbLinesValueError < RuntimeError
  end

  class InvalidNbLinesValueError < RuntimeError
  end
end
