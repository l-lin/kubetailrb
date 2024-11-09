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

        it 'should create FileReader with custom value if last_nb_lines and follow are provided' do
          filepath = 'README.md'

          actual = File.new(filepath: filepath, last_nb_lines: 3, follow: true)

          assert_equal 3, actual.reader.last_nb_lines
          assert actual.reader.follow?
        end
      end

      describe '.applicable?' do
        it 'should return true if the command line contains "--file" flag' do
          args = %w[--file test/test_helper.rb]

          actual = File.applicable?(*args)

          assert actual
        end

        it 'should return false if the command line does not contain "--file" flag' do
          args_arr = given_arguments_without_file_flag

          args_arr.each do |args|
            actual = File.applicable?(*args)

            refute actual
          end
        end

        def given_arguments_without_file_flag
          [
            [],
            ['foobar'],
            ['--version'],
            ['foobar', '--follow']
          ]
        end
      end

      describe '.create' do
        it 'should return file command with default last nb lines if given a filepath and no `--tail` flag' do
          args = %w[--file test/test_helper.rb]

          actual = File.create(*args)

          assert_instance_of File, actual
          assert_equal 'test/test_helper.rb', actual.reader.filepath
          assert_equal 10, actual.reader.last_nb_lines
          refute actual.reader.follow?
        end

        it 'should return file command with custom last nb lines if given a filepath, `--tail` and `--follow` flags' do
          args = %w[--file test/test_helper.rb --tail 3 --follow]

          actual = File.create(*args)

          assert_instance_of File, actual
          assert_equal 'test/test_helper.rb', actual.reader.filepath
          assert_equal 3, actual.reader.last_nb_lines
          assert actual.reader.follow?
        end

        it 'should raise InvalidNbLinesValueError if given a filepath and an invalid `--tail` flag value' do
          args = %w[--file test/test_helper.rb --tail invalid]

          actual = assert_raises(InvalidNbLinesValueError) { File.create(*args) }

          assert_equal 'Invalid --tail value: invalid.', actual.message
        end

        it 'should raise MissingNbLinesValueError if given a filepath and a `--tail` flag with no value' do
          args = %w[--file test/test_helper.rb --tail]

          actual = assert_raises(MissingNbLinesValueError) { File.create(*args) }

          assert_equal 'Missing --tail value.', actual.message
        end

        it 'should raise MissingFileError if not given a filepath' do
          args = %w[--file]

          actual = assert_raises(MissingFileError) { File.create(*args) }

          assert_equal 'Missing --file value.', actual.message
        end

        it 'should raise NoSuchFileError if not given a filepath and provided another flag' do
          args = %w[--file --tail 3]

          actual = assert_raises(NoSuchFileError) { File.create(*args) }

          assert_equal '--tail not found', actual.message
        end
      end
    end
  end
end
