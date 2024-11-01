# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  module Cmd
    class VersionTest < Minitest::Test
      describe '.applicable?' do
        it 'should return true if "--version" or "-v" flag is present in the arguments' do
          args_arr = given_arguments_with_version_flag

          args_arr.each do |args|
            actual = Version.applicable?(*args)

            assert actual
          end
        end

        it 'should return false if there is no "-v" or "--version" flag' do
          args_arr = given_arguments_without_version_flag

          args_arr.each do |args|
            actual = Version.applicable?(*args)

            refute actual
          end
        end

        def given_arguments_with_version_flag
          [
            ['-v'],
            ['--version'],
            ['--some-flag', '-v'],
            ['-v', '--some-flag']
          ]
        end

        def given_arguments_without_version_flag
          [
            nil,
            [],
            ['--help'],
            ['--some-flag'],
            ['foobar']
          ]
        end
      end

      describe '.execute' do
        before do
          @cmd = Version.new
        end

        it 'should display the version' do
          assert_output("#{VERSION}\n") { @cmd.execute }
        end
      end
    end
  end
end
