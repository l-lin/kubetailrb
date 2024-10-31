# frozen_string_literal: true

# NOTE: This file was generated using the following command:
# bundle gem kubetailrb --bin --no-coc --no-ext --mit --test=minitest --ci=github --linter=rubocop
# For more information and examples about making a new gem, check out our
# guide at: https://bundler.io/guides/creating_gem.html

require_relative 'lib/kubetailrb/version'

Gem::Specification.new do |spec|
  spec.name        = 'kubetailrb'
  spec.version     = Kubetailrb::VERSION
  spec.authors     = ['Louis Lin']
  spec.homepage    = 'https://github.com/l-lin/kubetailrb'
  spec.license     = 'MIT'
  spec.summary     = 'Tail k8s pod logs at the same time.'
  spec.description = <<~DESC
    Tail Kubernetes pod logs at the same time.

    Project used for learning Ruby and Rails.
  DESC

  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'bug_tracker_uri' => 'https://github.com/l-lin/kubetailrb/issues',
    'changelog_uri' => 'https://github.com/l-lin/kubetailrb/blob/main/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/l-lin/kubetailrb'
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  # NOTE: This will tell gem that there's an executable that should be installed to the user system.
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency 'example-gem', '~> 1.0'

  # NOTE: Add the following gems in the 'development' group by using `add_development_dependency` method.
  spec.add_development_dependency 'aruba', '~> 2.2.0'             # Test command-line applications
  spec.add_development_dependency 'cucumber', '~> 9.2.0'          # Tool for running tests in plain language.
  spec.add_development_dependency 'guard', '~> 2.19.0'            # Command-line tool to handle events on fs.
  spec.add_development_dependency 'guard-cucumber', '~> 3.0.0'    # Automatically runs your features.
  spec.add_development_dependency 'guard-minitest', '~> 2.4.6'    # Automatically run your tests with Minitest.
  spec.add_development_dependency 'minitest', '~> 5.16'           # Complete suite of testing facilities.
  spec.add_development_dependency 'pry'                           # Runtime dev console and IRB.
  spec.add_development_dependency 'pry-byebug'                    # Step-by-step debugging.
  spec.add_development_dependency 'rake', '~> 13.0'               # A Make-like build utility for Ruby.
  spec.add_development_dependency 'rubocop', '~> 1.21'            # Static code analyzer and formatter.
  spec.add_development_dependency 'rubocop-minitest', '~> 0.36.0' # Code style checking for Minitest files.
  spec.add_development_dependency 'rubocop-rake', '~> 0.6.0'      # Rubocop plugin for Rake.
  spec.add_development_dependency 'ruby-lsp'                      # Language Server for Ruby.
end
