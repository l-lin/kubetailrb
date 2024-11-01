# frozen_string_literal: true

require 'kubetailrb/file_reader'

module Kubetailrb
  module Cmd
    # Command to read a file.
    class File
      attr_reader :reader

      def initialize(filepath:, last_nb_lines:)
        @reader = Kubetailrb::FileReader.new(filepath: filepath, last_nb_lines: last_nb_lines)
      end

      def execute
        @reader.read
      end
    end
  end
end
