# frozen_string_literal: true

#
# Define some debugging behaviours to ease debugging sessions.
# src: https://github.com/deivid-rodriguez/pry-byebug?tab=readme-ov-file#matching-byebug-behaviour
#

if defined?(PryByebug)
  Pry.commands.alias_command "c", "continue"
  Pry.commands.alias_command "s", "step"
  Pry.commands.alias_command "n", "next"
  Pry.commands.alias_command "f", "finish"
end

# Hit Enter to repeat last command
Pry::Commands.command(/^$/, "repeat last command") do
  pry_instance.run_command Pry.history.to_a.last
end
