# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  module Cmd
    class HelpTest < Minitest::Test
      describe '.applicable?' do
        it 'should return true if no argument is given' do
          actual = Help.applicable?

          assert actual
        end

        it 'should return true if given "--help" or "-h" flag is present in the arguments' do
          args_arr = given_arguments_with_help_flag

          args_arr.each do |args|
            actual = Help.applicable?(*args)

            assert actual
          end
        end

        it 'should return false if there is no "-h" or "--help" flag' do
          args_arr = given_arguments_without_help_flag

          args_arr.each do |args|
            actual = Help.applicable?(*args)

            refute actual
          end
        end

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

        def given_arguments_without_help_flag
          [
            ['foobar'],
            ['--version'],
            ['foobar', '--follow']
          ]
        end
      end

      describe '.execute' do
        before do
          @cmd = Help.new
        end

        it 'should display help' do
          expected = <<~EXP
            Tail your Kubernetes pod logs at the same time.

            Usage:
              kubetailrb pod-query [flags]

            Flags:
              -v, --version  Display version.
              -h, --help     Display help.
                  --tail     The number of lines from the end of the logs to show. Defaults to 10.
              -f, --follow   Output appended data as the file grows.
          EXP

          assert_output(expected) { @cmd.execute }
        end
      end
    end
  end
end
