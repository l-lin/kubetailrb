# Kubetailrb

[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/HazAT/badge/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/kubetailrb?style=flat)](http://rubygems.org/gems/kubetailrb)

> Tail your Kubernetes pod logs at the same time.

> [!NOTE]
> This project is a pet project I used to learn the [Ruby programming language](https://www.ruby-lang.org/en/).
> So you might find lots of my [personal notes](./journey_log.md) in the codebase.
>
> If you want to have something that works, please look at the following
> projects that were used as inspirations instead:
>
> - https://github.com/stern/stern
> - https://github.com/johanhaleby/kubetail

![kubetailrb](./kubetailrb.png)

## Installation

```sh
gem install kubetailrb
```

If you want to install directly from the repository instead:

```sh
# Install dependencies.
./bin/setup

# Install gem onto your local machine
bundle exec rake install
```

## Usage

```bash
# show help
kubetailrb -h

# follow pod logs
kubetailrb 'clock' --namespace sandbox --raw

# follow pod structured JSON logs and display in human friendly way
kubetailrb 'clock-json' --namespace sandbox --follow
# or with shorter flags
kubetailrb 'clock-json' -n sandbox -f

# you can filter the pods using regex on the pod names
kubetailrb '^clock(?!-json)' -n sandbox -f

# you can also filter the containers using regex on the container names
kubetailrb 'clock' -n sandbox -f -c 'json'
```

## Development

```bash
# Open interactive prompt to allow you to experiment.
./bin/console

# Release new version
NEW_VERSION=1.0.1 \
  && sed "s/VERSION = \".*\"/VERSION = \"${NEW_VERSION}\"/" lib/kubetailrb/version.rb
  && bundle exec rake release

# Check available tasks that can be run
bundle exec rake --tasks

# During your development phase, run tests automatically.
bundle exec rake test:watch

# Run tests, cucumber features and lint.
bundle exec rake
```

## Release a new version

Update the version in
[`lib/kubetailrb/version.rb`](./lib/kubetailrb/version.rb).

> [!WARNING]
> You may have to update the tests...
> Too lazy to update the script to also update the tests...

Then execute the script:

```sh
./bin/release
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/l-lin/kubetailrb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
