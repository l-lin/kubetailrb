# frozen_string_literal: true

require "kubetailrb/version"

module Kubetailrb
  module Cmd
    # Get application version.
    class Version
      def execute
        puts VERSION
      end
    end
  end
end
