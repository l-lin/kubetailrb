# frozen_string_literal: true

require 'kubetailrb/validated'

module Kubetailrb
  module Filter
    # Filter the logs that we do not want to see.
    # Currently only supporting excluding access logs and datadog logs.
    class LogFilter
      include Validated

      def self.create(exclude)
        new(exclude.include?('access-logs'), exclude.include?('dd-logs'))
      end

      def initialize(exclude_access_logs, exclude_dd_logs)
        @exclude_access_logs = exclude_access_logs
        @exclude_dd_logs = exclude_dd_logs

        validate
      end

      # Returns true if the log should be print, false otherwise.
      def test(log)
        return false if @exclude_access_logs && access_log?(log)
        return false if @exclude_dd_logs && dd_log?(log)

        true
      end

      def exclude_access_logs?
        @exclude_access_logs
      end

      def exclude_dd_logs?
        @exclude_dd_logs
      end

      private

      def validate
        validate_boolean @exclude_access_logs, "Invalid exclude_access_logs: #{@exclude_access_logs}."
        validate_boolean @exclude_dd_logs, "Invalid exclude_dd_logs: #{@exclude_dd_logs}."
      end

      def access_log?(log)
        json = JSON.parse(log)
        # NOTE: Shall I mutualize this function, as it's also used in
        # JsonFormatter? It's only implemented in 2 places... Maybe I shall wait
        # until there's a third one before applying DRY.
        json.include?('http.response.status_code') || json.include?('http_status')
      rescue JSON::ParserError
        false
      end

      def dd_log?(log)
        # NOTE: Is there's a better way to detect if it's a datadog log?
        log.include?('[dd') || log.include?('[datadog]')
      end
    end
  end
end
