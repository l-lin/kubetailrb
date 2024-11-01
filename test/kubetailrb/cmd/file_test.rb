# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  module Cmd
    class FileTest < Minitest::Test
      describe '.new' do
        it 'should raise an error if the file does not exist' do
          filepath = 'non-existent'

          actual = assert_raises(Kubetailrb::NoSuchFileError) { File.new(filepath: filepath, last_nb_lines: 10) }

          assert_equal 'non-existent not found', actual.message
        end
      end
    end
  end
end
