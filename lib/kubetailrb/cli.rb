# frozen_string_literal: true

require_relative 'opts_parser'
require_relative 'cmd/file'
require_relative 'cmd/help'
require_relative 'cmd/version'

module Kubetailrb
  # CLI application to run kubetailrb.
  class CLI
    def execute(*args)
      cmd = OptsParser.new(*args).parse

      # NOTE: Is it better to use this approach by checking the method existence
      # or is it better to use a raise/rescue approach? Or another approach?
      raise 'Invalid cmd' unless cmd.respond_to?(:execute)

      cmd.execute

      # TODO: Implement graceful shutdown in case of error.
    end
  end
end
