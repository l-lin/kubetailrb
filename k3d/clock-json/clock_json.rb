# frozen_string_literal: true

require('json')

def print_log
  now = "#{Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%3N")}Z"
  {
    '@timestamp' => now,
    'log.level' => 'INFO',
    'message' => "Time is #{now}"
  }
end

loop do
  puts JSON[print_log]
  sleep 1
  $stdout.flush
end
