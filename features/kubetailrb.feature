Feature: Kubetailrb
  Scenario: No argument
    When I run `kubetailrb`
    Then the output should contain "TODO: display help"

  Scenario: Display version
    When I run `kubetailrb --version`
    Then the output should contain "0.1.0"
