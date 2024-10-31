# frozen_string_literal: true

module Kubetailrb
  module Cmd
    # Command to read a file.
    class File
      attr_reader :filepath

      def initialize(filepath)
        raise NoSuchFileError, "#{filepath} not found" unless ::File.exist?(filepath)

        @filepath = filepath
      end

      def execute
        # NOTE: Use `::` to ensure we are using the one from stdlib!!!
        ::File.open(@filepath) do |file|
          file.each { |line| puts line }
        end
      end
    end

    # NOTE: We can create custom exceptions by extending RuntimeError.
    class NoSuchFileError < RuntimeError
    end
  end
end
