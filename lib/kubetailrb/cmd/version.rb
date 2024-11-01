# frozen_string_literal: true

module Kubetailrb
  module Cmd
    # Get application version.
    class Version
      FLAGS = %w[-v --version].freeze

      def execute
        puts VERSION
      end

      def self.applicable?(*args)
        args.any? { |arg| FLAGS.include?(arg) }
      end
    end
  end
end
