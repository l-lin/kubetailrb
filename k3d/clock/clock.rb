# frozen_string_literal: true

loop do
  puts Time.now
  sleep 1
  # NOTE: You need to flush stdout so that it's printed out in the console!
  $stdout.flush
end
