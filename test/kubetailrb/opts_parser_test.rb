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

      # it '' do
      #
      # end
      #
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
