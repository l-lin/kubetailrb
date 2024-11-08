# frozen_string_literal: true

# NOTE: For some weird reason I do not understand, logs are not display in the
# kubernetes pod, at least until the pod is stopped, e.g. if I do not use an
# infinite loop, but use `10.times` for example, the logs will be displayed at
# once after 10s. If I use a plain old `docker run`, the logs are displayed
# correctly in stream...
# So for now, I'm using the shell variant, since I do not want to investigate
# too much in this issue...
loop do
  puts Time.now
  sleep 1
end
