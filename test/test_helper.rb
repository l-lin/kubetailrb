# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'kubetailrb'

require 'minitest/autorun'
require 'webmock/minitest'

# Shamelessly copied from https://github.com/ManageIQ/kubeclient/blob/master/test/helper.rb#L13-L30.
Minitest::Test.class_eval do
  # Assumes test files will be in a subdirectory with the same name as the
  # file suffix.  e.g. a file named foo.json would be a "json" subdirectory.
  def open_test_file(name)
    File.new(File.join(File.dirname(__FILE__), name.split('.').last, name))
  end

  def stub_core_api_list
    stub_request(:get, %r{/api/v1$})
      .to_return(body: open_test_file('core_api_resource_list.json'), status: 200)
  end
end
