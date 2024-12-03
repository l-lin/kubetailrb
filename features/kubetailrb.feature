Feature: Kubetailrb
  Scenario: Display help
    When I run `kubetailrb --help`
    Then the output should contain:
"""
Tail your Kubernetes pod logs at the same time.

Usage:
  kubetailrb pod-query [flags]

Flags:
  -v, --version   Display version.
  -h, --help      Display help.
      --tail      The number of lines from the end of the logs to show. Defaults to 10.
  -f, --follow    Output appended data as the file grows.
      --file      Display file content.
  -r, --raw       Only display pod logs.
  -n, --namespace Kubernetes namespace to use.
  -c, --container Container name when multiple containers in pod. Default to '.'.
"""

  Scenario: No argument
    When I run `kubetailrb`
    Then the output should contain:
"""
Tail your Kubernetes pod logs at the same time.

Usage:
  kubetailrb pod-query [flags]

Flags:
  -v, --version   Display version.
  -h, --help      Display help.
      --tail      The number of lines from the end of the logs to show. Defaults to 10.
  -f, --follow    Output appended data as the file grows.
      --file      Display file content.
  -r, --raw       Only display pod logs.
  -n, --namespace Kubernetes namespace to use.
  -c, --container Container name when multiple containers in pod. Default to '.'.
"""

  Scenario: Display version
    When I run `kubetailrb --version`
    Then the output should contain "0.1.0"

  # NOTE: Tests are not executed at project root folder, but under 'tmp/aruba'!
  Scenario: Display file content
    When I run `kubetailrb --file ../../test/test_helper.rb`
    Then the output should contain:
"""
  # file suffix.  e.g. a file named foo.json would be a "json" subdirectory.
  def open_test_file(name)
    File.new(File.join(File.dirname(__FILE__), name.split('.').last, name))
  end

  def stub_core_api_list
    stub_request(:get, %r{/api/v1$})
      .to_return(body: open_test_file('core_api_resource_list.json'), status: 200)
  end
end
"""

  Scenario: Display partial file content
    When I run `kubetailrb --file ../../test/test_helper.rb --tail 1`
    Then the output should contain:
"""
end
"""
