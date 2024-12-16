## [0.3.2] - 2024-12-16

- support `DEBUG` and `TRACE` levels

## [0.3.1] - 2024-12-13

- fix reading rails log messages

## [0.3.0] - 2024-12-11

- rename `--exclude` flag to `--excludes`
- add `--mdcs` flag to include specific MDCs

## [0.2.0] - 2024-12-05

- remove `--pretty` flag
  - now by default, it's displayed in pretty mode
  - to display the log without formatting, use `--raw` flag
- add possibility to filter out the access and datadog logs
- support displaying stack trace in pretty mode
- support formatting rails logs
- fix color when receiving HTTP 500 in access logs
- add `--display-names` flag to display the pod and container names
- colorize pod events (blue for new pod events, red for deleted pod events)

## [0.1.0] - 2024-10-27

- Initial release

## [Unreleased]
