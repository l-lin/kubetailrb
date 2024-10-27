# frozen_string_literal: true

require "optparse"
require_relative "cmd/help"
require_relative "cmd/version"

module Kubetailrb
  # CLI application to run kubetailrb.
  class CLI
    def self.execute
      new.execute!
    end

    def initialize
      @cmd = :help
    end

    def execute!
      parse_opts!

      cmd = create_cmd
      # TODO: Check if `execute` method exists, to leverage duck typing.
      cmd.execute

      # TODO: Implement graceful shutdown in case of error.
    end

    private

    def parse_opts!
      OptionParser.new do |opts|
        opts.on("-v", "--version", "Dispay version") do
          @cmd = :version
        end
      end.parse!
    end

    def create_cmd
      # NOTE: We can use switch case with symbols and for strings!
      case @cmd
      when :help
        Kubetailrb::Cmd::Help.new
      when :version
        Kubetailrb::Cmd::Version.new
      else
        raise NotImplementedError
      end
    end
  end
end
