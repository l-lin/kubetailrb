# frozen_string_literal: true

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
