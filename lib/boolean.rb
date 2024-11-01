# frozen_string_literal: true

#
# Just a simple module to represent a boolean in Ruby, as it appears there's
# not much to know if an object is a boolean or not...
# So I'll use this occasion to override some native classes like suggested.
# src: https://stackoverflow.com/a/3028378/3612053
#
module Boolean
end

# Include the `Boolean` module to native `TrueClass` so I can do something liks
# this: true.is_a?(Boolean).
class TrueClass
  include Boolean
end

# Include the `Boolean` module to native `TrueClass` so I can do something liks
# this: false.is_a?(Boolean).
class FalseClass
  include Boolean
end
