# frozen_string_literal: true

module Kubetailrb
  module Cmd
    class VersionTest < Minitest::Test
      describe "Version command" do
        before do
          @cmd = Version.new
        end

        it "should display the version" do
          assert_output("#{VERSION}\n") { @cmd.execute }
        end
      end
    end
  end
end
