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
      return Cmd::Help.new if Cmd::Help.applicable?(*@args)

      return Cmd::Version.new if Cmd::Version.applicable?(*@args)

      return Cmd::File.create(*@args) if Cmd::File.applicable?(*@args)

      Cmd::K8s.create(*@args)
    end
  end
end
