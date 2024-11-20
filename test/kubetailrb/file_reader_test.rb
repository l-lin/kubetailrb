# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  class FileReaderTest < Minitest::Test
    EXISTING_FILE = 'README.md'
    NON_EXISTING_FILE = 'non-existent'

    describe '.new' do
      it 'should raise an error if the file does not exist' do
        actual = assert_raises(NoSuchFileError) do
          FileReader.new(filepath: NON_EXISTING_FILE, last_nb_lines: 10, follow: false)
        end

        assert_equal 'non-existent not found', actual.message
      end

      it 'should raise an error if the last nb lines is invalid' do
        given_invalid_last_nb_lines.each do |invalid_last_nb_lines|
          actual = assert_raises(ArgumentError) do
            FileReader.new(filepath: EXISTING_FILE, last_nb_lines: invalid_last_nb_lines, follow: false)
          end

          assert_equal "Invalid last_nb_lines: #{invalid_last_nb_lines}.", actual.message
        end
      end

      it 'should raise an error if follow is invalid' do
        given_invalid_follow.each do |follow|
          actual = assert_raises(ArgumentError) do
            FileReader.new(filepath: EXISTING_FILE, last_nb_lines: 10, follow: follow)
          end

          assert_equal "Invalid follow: #{follow}.", actual.message
        end
      end

      it 'should create a FileReader with valid arguments' do
        actual = FileReader.new(filepath: EXISTING_FILE, last_nb_lines: 3, follow: true)

        assert_equal 3, actual.last_nb_lines
        assert actual.follow?
      end

      private

      def given_invalid_last_nb_lines
        [
          0,
          -1,
          'a string'
        ]
      end

      def given_invalid_follow
        [
          nil,
          [],
          0,
          -1,
          'a string'
        ]
      end
    end

    describe '.read' do
      it 'should read the file content' do
        file_reader = FileReader.new(filepath: EXISTING_FILE, last_nb_lines: 3, follow: false)

        expected = <<~EXPECTED
          ## License

          The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
        EXPECTED
        assert_output(expected) { file_reader.read }
      end

      it 'should read empty if the file content is empty' do
        file_reader = FileReader.new(filepath: 'test/empty_file.txt', last_nb_lines: 3, follow: false)

        assert_output('') { file_reader.read }
      end

      it 'should read all the file content if nb_last_lines is greater than file line numbers' do
        file_reader = FileReader.new(filepath: 'test/one_line.txt', last_nb_lines: 3, follow: false)

        assert_output("just one line\n") { file_reader.read }
      end
    end
  end
end
