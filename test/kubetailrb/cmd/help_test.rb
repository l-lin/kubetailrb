# frozen_string_literal: true

require 'test_helper'

module Kubetailrb
  module Cmd
    class HelpTest < Minitest::Test
      describe 'help command' do
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
