# Kubetailrb

:construction: WIP.

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

## Installation

Add the gem to your `Gemfile`:

```ruby
gem 'kubetailrb', github: 'l-lin/kubetailrb'
```

## Usage

```bash
kubetailrb -h
```

## Development

```bash
# Install dependencies.
./bin/setup

# Run tests, cucumber features and lint.
rake

# Open interactive prompt to allow you to experiment.
./bin/console

# Install gem onto your local machine
bundle exec rake install

# Release new version
NEW_VERSION=1.0.1 \
  && sed "s/VERSION = \".*\"/VERSION = \"${NEW_VERSION}\"/" lib/kubetailrb/version.rb
  && bundle exec rake release

# During your development phase, run tests automatically.
guard -c
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/l-lin/kubetailrb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
