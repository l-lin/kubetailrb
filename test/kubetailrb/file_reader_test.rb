# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  class FileReaderTest < Minitest::Test
    describe '.new' do
      it 'should raise an error if the file does not exist' do
        filepath = 'non-existent'

        actual = assert_raises(NoSuchFileError) { FileReader.new(filepath: filepath, last_nb_lines: 10) }

        assert_equal 'non-existent not found', actual.message
      end

      it 'should raise an error if the last nb lines is invalid' do
        filepath = 'README.md'

        given_invalid_last_nb_lines.each do |invalid_last_nb_lines|
          actual = assert_raises(InvalidArgumentError) do
            FileReader.new(filepath: filepath, last_nb_lines: invalid_last_nb_lines)
          end

          assert_equal "Invalid last_nb_lines: #{invalid_last_nb_lines}.", actual.message
        end
      end

      private

      def given_invalid_last_nb_lines
        [
          0,
          -1,
          'a string'
        ]
      end
    end

    describe '.read' do
      it 'should read the file content' do
        filepath = 'README.md'
        file_reader = FileReader.new(filepath: filepath, last_nb_lines: 3)

        expected = <<~EXPECTED
          ## License

          The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
        EXPECTED
        assert_output(expected) { file_reader.read }
      end
    end
  end
end
