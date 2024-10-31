# frozen_string_literal: true

module Kubetailrb
  # Parse CLI arguments and flags.
  # NOTE: We could use the standard library optparse (OptionParser) or a more
  # comprehensive tool like Thor to achieve this, but that would defeat the
  # purpose of learning by implementing it ourselves.
  class OptsParser
    def self.parse(*args)
      return Cmd::Help.new if args.nil?

      return Cmd::Version.new if args.any? { |arg| ["-v", "--version"].include?(arg) }

      Cmd::Help.new
    end
  end
end
