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
      return Cmd::Help.new if missing_args? || contains_flags?(['-h', '--help'])

      return Cmd::Version.new if contains_flags?(['-v', '--version'])

      Cmd::Help.new
    end

    private

    def missing_args?
      @args.nil? || @args.empty?
    end

    def contains_flags?(flags)
      @args.any? { |arg| flags.include?(arg) }
    end
  end
end
