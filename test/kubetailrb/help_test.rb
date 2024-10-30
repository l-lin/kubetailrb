# frozen_string_literal: true

module Kubetailrb
  module Cmd
    class HelpTest < Minitest::Test
      describe "help command" do
        before do
          @cmd = Help.new
        end

        it "should display help" do
          expected = <<~EXP
            Tail your Kubernetes pod logs at the same time.

            Usage:
              kubetailrb pod-query [flags]

            Flags:
              -v, --version  Display version.
              -h, --help     Display help.
          EXP

          assert_output(expected) { @cmd.execute }
        end
      end
    end
  end
end
