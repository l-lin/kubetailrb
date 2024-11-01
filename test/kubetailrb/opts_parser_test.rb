# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  class OptsParserTest < Minitest::Test
    describe '.parse' do
      it 'should return help command if no argument is given' do
        actual = OptsParser.new.parse

        assert_instance_of Cmd::Help, actual
      end

      it 'should return help command if given "--help" or "-h" flag is present in the arguments' do
        args_arr = given_arguments_with_help_flag

        args_arr.each do |args|
          actual = OptsParser.new(*args).parse

          assert_instance_of Cmd::Help, actual, "Expected Help command with arguments #{args}"
        end
      end

      it 'should return version command if given "--version" or "-v" flag is present in the arguments' do
        args_arr = given_arguments_with_version_flag

        args_arr.each do |args|
          actual = OptsParser.new(*args).parse

          assert_instance_of Cmd::Version, actual, "Expected Version command with arguments #{args}"
        end
      end

      it 'should return file command with default last nb lines if given a filepath and no `--tail` flag' do
        opts_parser = OptsParser.new('test/test_helper.rb')

        actual = opts_parser.parse

        assert_instance_of Cmd::File, actual
        assert_equal 'test/test_helper.rb', actual.reader.filepath
        assert_equal 10, actual.reader.last_nb_lines
      end

      it 'should return file command with custom last nb lines if given a filepath and a `--tail` flag' do
        opts_parser = OptsParser.new('test/test_helper.rb', '--tail', '3')

        actual = opts_parser.parse

        assert_instance_of Cmd::File, actual
        assert_equal 'test/test_helper.rb', actual.reader.filepath
        assert_equal 3, actual.reader.last_nb_lines
      end

      it 'should raise InvalidNbLinesValueError if given a filepath and an invalid `--tail` flag value' do
        opts_parser = OptsParser.new('test/test_helper.rb', '--tail', 'invalid')

        actual = assert_raises(InvalidNbLinesValueError) { opts_parser.parse }

        assert_equal 'Invalid --tail value: invalid.', actual.message
      end

      it 'should raise MissingNbLinesValueError if given a filepath and a `--tail` flag with no value' do
        opts_parser = OptsParser.new('test/test_helper.rb', '--tail')

        actual = assert_raises(MissingNbLinesValueError) { opts_parser.parse }

        assert_equal 'Missing --tail value.', actual.message
      end

      private

      def given_arguments_with_help_flag
        [
          nil,
          [],
          ['-h'],
          ['--help'],
          ['--some-flag', '-h'],
          ['-h', '--some-flag']
        ]
      end

      def given_arguments_with_version_flag
        [
          ['-v'],
          ['--version'],
          ['--some-flag', '-v'],
          ['-v', '--some-flag']
        ]
      end
    end
  end
end
