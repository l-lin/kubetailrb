# frozen_string_literal: true

require 'kubetailrb/painter'
require 'kubetailrb/validated'

module Kubetailrb
  module Formatter
    # Format JSON to human readable.
    class JsonFormatter
      include Painter
      include Validated

      def initialize(mdcs = [])
        @mdcs = mdcs

        validate
      end

      def format(log)
        json = JSON.parse(log)

        return format_access_log(json) if access_log?(json)

        format_application_log(json)
      rescue JSON::ParserError
        log
      end

      private

      def validate
        raise_if_nil @mdcs, 'MDCs not set.'
      end

      def access_log?(json)
        json.include?('http.response.status_code') || json.include?('http_status')
      end

      def format_access_log(json)
        "#{json["@timestamp"]}#{format_http_status_code json}#{http_method json} #{url_path json}"
      end

      def format_application_log(json)
        "#{json["@timestamp"]}#{format_log_level json}#{format_mdcs json}#{json["message"]}#{format_stack_trace json}"
      end

      def format_stack_trace(json)
        stack_trace = json['error.stack_trace']

        return '' if stack_trace.nil? || stack_trace.strip&.empty?

        "\n#{stack_trace}"
      end

      def format_http_status_code(json)
        code = json['http.response.status_code'] || json['http_status']

        return " #{highlight_blue(" I ")} [#{code}] " if code >= 200 && code < 400
        return " #{highlight_yellow(" W ")} [#{code}] " if code >= 400 && code < 500
        return " #{highlight_red(" E ")} [#{code}] " if code >= 500

        " #{code} "
      end

      def format_log_level(json)
        level = json['log.level'] || json.dig('log', 'level')
        return ' ' if level.nil? || level.strip.empty?
        return " #{highlight_blue(" I ")} " if level == 'INFO'
        return " #{highlight_yellow(" W ")} " if level == 'WARN'
        return " #{highlight_red(" E ")} " if level == 'ERROR'

        " #{level} "
      end

      def http_method(json)
        json['http.request.method'] || json['http_method']
      end

      def url_path(json)
        json['url.path'] || json['http_path']
      end

      def format_mdcs(json)
        result = ''
        @mdcs.each do |mdc|
          value = json[mdc] || json.dig(*mdc.split('.'))
          result += "#{cyan("#{mdc}=#{value}")} " unless value.nil?
        end
        result.to_s
      end
    end
  end
end
