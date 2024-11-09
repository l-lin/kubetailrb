# frozen_string_literal: true

module Kubetailrb
  # Format JSON to human readable.
  class JsonFormatter
    def format(log)
      json = JSON.parse(log)
      "#{json["@timestamp"]} #{json["log.level"]} #{json["message"]}"
    rescue JSON::ParserError
      log
    end
  end
end
