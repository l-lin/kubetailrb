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
"""

  Scenario: Display version
    When I run `kubetailrb --version`
    Then the output should contain "0.1.0"
