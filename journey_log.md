# Journey log

> Here lies the chronicle of my journey learning Ruby, a collection of trials,
> tribulations, and triumphs as I navigated the world of this dynamic
> programming language.


## 🤔 Things that I'm curious about
### Double colons

```ruby
# Sometime, we are prefixing the class with ::
some_var = ::SomePackage::SomeClass

# Some other time, we do not
some_var = SomePackage::SomeClass
```

I believe the first one is to avoid collision. So then, why not always writing
the first one? Why bother writing the second form, if there's a risk of
collision?

### On duck typing

Duck typing is really powerful and can make one program flexible and decouple
code.

However, how does one can keep easily keep track of which classes are
implementing a particular behavior? If we want to rename a method, how can we
ensure all the implementations are also updated?

With static typed programming language, we have the compiler to help us track
and update the method name.
For small projects, it is manageable and can be updated with careful `grep`, but
for really large projects (hundred thousands to millions of LoC), how can one
keep ~~their sanity~~track of the class methods?

### Getter on boolean

We can easily add getters with the keyword `attr_reader`. However, by
convention, methods that return a boolean should have the suffix `?`.

But `attr_reader` does not seem to add this suffix `?` to the boolean variable
(which is logical, since Ruby is a dynamic programming language, so it cannot
know in advance if the variable is boolean or not).

Do we have to manually implement this getter?

```ruby
class Foobar
  def initialize
    @foo = true
  end

  def foo?
    @foo
  end
end
```

### On ensure

While I was implementing the `FileReader`, I must close the file regardless of
the result (otherwise, bad things may happen).

So, I used the `rescue` keyword:

```ruby
def foobar
  file = File.open('/path/to/file')
  # so some stuff with file
ensure
  file&.close
end
```

Is it the right way to do it? Is there a better way?

---

## 2024-10-27
### Context

I already learned some basic Ruby by reading the
[official Ruby documentation](https://www.ruby-lang.org/en/) as well as doing
the [Ruby Koans](https://www.rubykoans.com/).

Now it's time to the practical exercise by creating a new project.
Since I'm on the team to "embrace suffering to learn efficiently", I think
coding and meeting lots of issue while I'm building this tool will heavily
benefit my Ruby skill and its ecosystem.

The subject of the exercise is to have something relevant to my day-to-day work,
something I'm sure I'll often use.

We are using Kubernetes at work (like most companies), and we are using
structured logs following the [Elastic Common Schema (ECS) specification](https://www.elastic.co/guide/en/ecs/current/ecs-reference.html),
so not quite easily readable by a human.

Tools like [stern](https://github.com/stern/stern) or [kubetail](https://github.com/johanhaleby/kubetail)
are useful to watch multiple Kubernetes pod logs directly from the terminal.
However, they do not format the logs in JSON format easily. I could pipe the
result and use other tools like [jq](https://github.com/jqlang/jq), but it's not
fun, and I wanted to really learn Ruby, hence this project was created.

Let's hope I will see it through and manage to implement the whole project 🤞.

### Project goal

The idea is to have a CLI, like [stern](https://github.com/stern/stern), to read
and follow the Kubernetes pod logs directly from the terminal, so something like
this:

```bash
kubetailrb --namespace my-namespace pod-name-regex
```

The name `kubetailrb` is copied from [kubetail](https://github.com/johanhaleby/kubetail)
with a simple prefix `rb` to indicate that it's implemented in Ruby, so quite
straightforward.

I want to have it like a library, so a Gem, that can also be used by other Ruby
project.
I also have the ambition to learn [Ruby on Rails](https://rubyonrails.org/), so
I also plan to implement a web version of `kubetailrb`.

### Project initialization

There are lots of way to create a new Ruby project.

I first went for the tutorial at [RubyGems](https://guides.rubygems.org/make-your-own-gem/).
It did work for a bit. However, the projects at my work are using [Bundler](https://bundler.io/),
which seems to better scale Ruby projects, in the sense that it can track and
manage dependencies with the idea of `Gemfile.lock`.

So I followed the [tutorial from Bundler](https://bundler.io/guides/creating_gem.html#testing-our-gem)
which is quite complete as it provides some boilerplate to quickly help me start
up a new project, like:

- the basic project structure,
- a `Gemfile` as well as the `kubetailrb.gemspec`,
- a `Rakefile` to execute some task, like running the tests.

The project generation was performed with a single command line:

```bash
bundle gem kubetailrb --bin --no-coc --no-ext --mit --test=minitest --ci=github --linter=rubocop
```

Lots of things to learn. Let's take it one by one.

### Project structure

It seems the convention is:

- `lib/` contains the source code.
- `test/` (or `spec/` depending on the test framework) contains the test code.
- `bin/` contains some scripts that can help the developer experience,
  - Rails projects also have scripts in this `bin/` directory.
- `exec/` contains the executables that will be installed to the user system if
  the latter is installing the gem
  - It seems to be a convention from Bundler, but that is configurable in the
  `gemspec` file.

I'm still not sure about the other directories, but I'll find out sooner or
later.

### Gemfile vs gemspec

The `Gemfile` is used to manage gem dependencies for our library’s development.
This file contains a `gemspec` line meaning that Bundler will include
dependencies specified in `kubetailrb.gemspec` too. It’s best practice to
specify all the gems that our library depends on in the `gemspec`.

The `gemspec` is the Gem Specification file. This is where we provide
information for Rubygems' consumption such as the name, description and homepage
of our gem. This is also where we specify the dependencies our gem needs to run.

> The benefit of putting this dependency specification inside of
> `foodie.gemspec` rather than the `Gemfile` is that anybody who runs gem
> install `foodie --dev` will get these development dependencies installed too.
> This command is used for when people wish to test a gem without having to fork
> it or clone it from GitHub.

src: https://bundler.io/guides/creating_gem.html#testing-our-gem

So, I'll put the dependencies to the `gemspec` by default. Looking at some
project, like [cucumber-ruby](https://github.com/cucumber/cucumber-ruby/tree/main), they are also putting everything in their `gemspec`.

### Rake

[Rake](https://github.com/ruby/rake) is a popular task runner in Ruby.

In a newly created project, it only runs the tests and the linter (Rubocop).

A good tutorial on Rake: https://www.rubyguides.com/2019/02/ruby-rake/

I wanted to add [cucumber](https://github.com/cucumber/cucumber-ruby/tree/main)
in the `:default` task so that it execute all the tests (minitest + cucumber).

To know how to add this step, I directly looked at the source code of
[cucumber-ruby](https://github.com/cucumber/cucumber-ruby/blob/main/lib/cucumber/rake/task.rb) and add it to my [Rakefile](./Rakefile):

```ruby
# ... previous code

require "cucumber/rake"
Cucumber::Rake::Task.new

task default: %i[test cucumber rubocop]
```

### `require` vs `require_relative`

Difference between `require` and `require_relative`:
- `require` is global.
- `require_relative` is relative to this current directory of this file.
- `require "./some_file"` is relative to your current working directory.

src: https://stackoverflow.com/a/3672600/3612053

### Create a Ruby CLI application

We can parse CLI options using only stdlib.
No need to use some fancy library, like Thor or cli-ui.
The goal is to learn Ruby, not to learn to use 3rd party libraries.

src: https://www.rubyguides.com/2018/12/ruby-argv/

Some tools if I ever decide to change mind:

- [rails/thor: Thor is a toolkit for building powerful command-line interfaces](https://github.com/rails/thor)
- [TTY: The Ruby terminal apps toolkit](https://ttytoolkit.org/)
- [Shopify/cli-ui: CLI tooling framework with simple interactive widgets](https://github.com/Shopify/cli-ui?tab=readme-ov-file)

### Bundle exec everything?

The documentation is always prefixing all the command with `bundle exec`, e.g.
`bundle exec rake`. But I already have `rake` in my `$PATH`, so why do they
suggest adding this `bundle exec` which seems to provide more typing.

> In some cases, running executables without bundle exec may work, if the
> executable happens to be installed in your system and does not pull in any
> gems that conflict with your bundle.
>
> However, this is unreliable and is the source of considerable pain. Even if it
> looks like it works, it may not work in the future or on another machine.

src: https://stackoverflow.com/a/6588708/3612053

## 2024-10-29
### RUBYGEMS_GEMDEPS env variable

Previously, to ensure we are using the right gems, we needed to prefix all our
ruby/gem commands with `bundle exec`. But it seems there's a better way: set the
`RUBYGEMS_GEMDEPS=-` environment variable. This will autodetect the `Gemfile` in
the current or parent directories or set it to the path of your `Gemfile`.

> `use_gemdeps(path = nil)`
>
> Looks for a gem dependency file at path and
> activates the gems in the file if found. If the file is not found an
> ArgumentError is raised.
>
> If path is not given the RUBYGEMS_GEMDEPS environment variable is used, but if
> no file is found no exception is raised.
>
> If ‘-’ is given for path RubyGems searches up from the current working
> directory for gem dependency files (gem.deps.rb, Gemfile, Isolate) and
> activates the gems in the first one found.
>
> You can run this automatically when rubygems starts. To enable, set the
> RUBYGEMS_GEMDEPS environment variable to either the path of your gem
> dependencies file or “-” to auto-discover in parent directories.
>
> NOTE: Enabling automatic discovery on multiuser systems can lead to execution
> of arbitrary code when used from directories outside your control.

src: https://ruby-doc.org/3.3.5/stdlibs/rubygems/Gem.html

### Guard to execute tests automatically

I want to have fast feedback loop, and to get this developer experience, I need
something that will run automatically the tests every time I update a file.

I could have use [entr](https://github.com/clibs/entr) as usual, but since I'm
learning Ruby, let's try to keep on Ruby's ecosystem.

And it appears there's a tool for that: [Guard](https://github.com/guard/guard).

It's quite powerful, especially because it's also offering several plugins to
support multiple use cases, such as
[guard-minitest](https://rubygems.org/gems/guard-minitest) to run Minitest and
Test/Unit tests, and [guard-cucumber](https://github.com/guard/guard-cucumber)
to re-run changed/affected Cucumber features.

## 2024-10-30
### Debugging

I thought the keyword `pry` was native to Ruby. It appears I need to add some
gems to enable debugging:

```ruby
spec.add_development_dependency "pry"
spec.add_development_dependency "pry-byebug"
```

The latter is needed to go step-by-step. I also have to add a `.pryrc` at the
root of the project in order to have some nice shortcuts, like `n` for `next`.

To add a breaking point, I had to add:

```ruby
require "pry"
require "pry-byebug"

binding.pry
```

## 2024-10-31
### Require in tests

I tried to test my [`OptsParser`](./lib/kubetailrb/opts_parser.rb) with
[`OptsParserTest`](./test/kubetailrb/opts_parser_test.rb), but I got an error
while creating a new instance:

```
  1) Error:
no argument provided#test_0001_should return help command:
NameError: uninitialized constant Kubetailrb::OptsParser
    test/kubetailrb/opts_parser_test.rb:7:in `block (2 levels) in <class:OptsParserTest>'
```

So I had to add the following to my test file:

```ruby
require "kubetailrb/opts_parser"
```

But do I not need to add this line for [`VersionTest`](./test/kubetailrb/cmd/version_test.rb) and [`HelpTest`](./test/kubetailrb/cmd/help_test.rb)?

It was because I had the following in my
[`CLI`](./lib/kubetailrb/cli.rb):

```ruby
require "cmd/help"
require "cmd/version"
```

which include my classes.

### Method verb conjugation

I wanted to check if a `String` started with some prefix `-`, so I figured there
was a method to do it, like most programming language:

```ruby
'some string'.starts_with?("some")
```

But then, I got an error:

```
NoMethodError: undefined method `starts_with?' for an instance of String
```

It appears it was a typo and maybe it's a convention to have the verb be in
infinitive form, so in this case `start_with`, but not for all methods, e.g. `is_a?`.

### Executing shell commands directly from Ruby code

It's quite easy to execute some shell commands directly from Ruby code! I was
quite impressed by the simplicity:

```ruby
# using Kernel#`
with_backtick = `ls`
# or with %x
another_way = %x|ls|
```

src: https://www.rubyguides.com/2018/12/ruby-system/

### On default argument

There's a particular behavior that I did not expect for default argument.

Let's say, we have the following method:

```ruby
def foobar(var = 1)
  puts var
end

foobar # will print: 1

foobar(nil) # will print nothing
```

So `nil` will not make the method use the default argument. It's by design, so
be careful when using those default argument.

src: https://stackoverflow.com/a/10506137/3612053
