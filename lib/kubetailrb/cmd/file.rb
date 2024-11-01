# frozen_string_literal: true

require 'kubetailrb/file_reader'

module Kubetailrb
  module Cmd
    # Command to read a file.
    class File
      attr_reader :reader

      def initialize(filepath:, last_nb_lines: 10, follow: false)
        @reader = Kubetailrb::FileReader.new(filepath: filepath, last_nb_lines: last_nb_lines, follow: follow)
      end

      def execute
        @reader.read
      end
    end
  end
end
