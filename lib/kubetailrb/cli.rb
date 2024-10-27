# frozen_string_literal: true

# NOTE: Difference between `require` and `require_relative`:
# - `require` is global.
# - `require_relative` is relative to this current directory of this file.
# - `require "./some_file"` is relative to your current working directory.
# src: https://stackoverflow.com/a/3672600/3612053
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

    # NOTE: We can parse CLI options using stdlib.
    # No need to use some fancy library, like Thor or cli-ui.
    # The goal is to learn Ruby, not to learn to use 3rd party libraries.
    # src: https://www.rubyguides.com/2018/12/ruby-argv/
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
