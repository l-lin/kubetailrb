# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  module Cmd
    class FileTest < Minitest::Test
      describe '.new' do
        it 'should raise an error if the file does not exist' do
          filepath = 'non-existent'

          actual = assert_raises(Kubetailrb::NoSuchFileError) do
            File.new(filepath: filepath, last_nb_lines: 10, follow: false)
          end

          assert_equal 'non-existent not found', actual.message
        end

        it 'should create FileReader with default value if last_nb_lines and follow are not provided' do
          filepath = 'README.md'

          actual = File.new(filepath: filepath)

          assert_equal 10, actual.reader.last_nb_lines
          refute actual.reader.follow?
        end
      end
    end
  end
end
