# frozen_string_literal: true

module Kubetailrb
  # Formatter that does nothing except return what's given to it.
  class NoOpFormatter
    def format(log)
      log
    end
  end
end
