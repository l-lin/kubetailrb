Feature: Kubetailrb
  Scenario: Display help
    When I run `kubetailrb --help`
    Then the output should contain:
"""
Tail your Kubernetes pod logs at the same time.

Usage:
  kubetailrb pod-query [flags]

Flags:
  -v, --version  Display version.
  -h, --help     Display help.
      --tail     The number of lines from the end of the logs to show. Defaults to 10.
  -f, --follow   Output appended data as the file grows.
      --file     Display file content.
"""

  Scenario: No argument
    When I run `kubetailrb`
    Then the output should contain:
"""
Tail your Kubernetes pod logs at the same time.

Usage:
  kubetailrb pod-query [flags]

Flags:
  -v, --version  Display version.
  -h, --help     Display help.
      --tail     The number of lines from the end of the logs to show. Defaults to 10.
  -f, --follow   Output appended data as the file grows.
      --file     Display file content.
"""

  Scenario: Display version
    When I run `kubetailrb --version`
    Then the output should contain "0.1.0"

  # NOTE: Tests are not executed at project root folder, but under 'tmp/aruba'!
  Scenario: Display file content
    When I run `kubetailrb --file ../../test/test_helper.rb`
    Then the output should contain:
"""
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'kubetailrb'

require 'minitest/autorun'
require 'webmock/minitest'
"""

  Scenario: Display partial file content
    When I run `kubetailrb --file ../../test/test_helper.rb --tail 1`
    Then the output should contain:
"""
require 'webmock/minitest'
"""
