# frozen_string_literal: true

require "test_helper"

class TestKubetailrb < Minitest::Test
  describe "Main module" do
    it "has a version number" do
      refute_nil ::Kubetailrb::VERSION
    end
  end
end
