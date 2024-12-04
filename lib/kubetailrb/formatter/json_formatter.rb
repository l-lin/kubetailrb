# frozen_string_literal: true

module Kubetailrb
  module Formatter
    # Format JSON to human readable.
    class JsonFormatter
      def format(log)
        json = JSON.parse(log)

        return format_access_log(json) if access_log?(json)

        format_application_log(json)
      rescue JSON::ParserError
        log
      end

      private

      def access_log?(json)
        json.include?('http.response.status_code') || json.include?('http_status')
      end

      def format_access_log(json)
        "#{json["@timestamp"]}#{http_status_code json}#{http_method json} #{url_path json}"
      end

      def format_application_log(json)
        "#{json["@timestamp"]}#{log_level json}#{json["message"]}#{format_stack_trace json}"
      end

      def format_stack_trace(json)
        stack_trace = json['error.stack_trace']

        return '' if stack_trace.nil? || stack_trace.strip&.empty?

        "\n#{stack_trace}"
      end

      def http_status_code(json)
        code = json['http.response.status_code'] || json['http_status']

        return "#{blue(" I ")}[#{code}] " if code >= 200 && code < 400
        return "#{yellow(" W ")}[#{code}] " if code >= 400 && code < 500
        return "#{red(" E ")}[#{code}] " if code >= 500

        " #{code} "
      end

      def log_level(json)
        level = json['log.level'] || json.dig('log', 'level')
        return ' ' if level.nil? || level.strip.empty?
        return blue(' I ') if level == 'INFO'
        return yellow(' W ') if level == 'WARN'
        return red(' E ') if level == 'ERROR'

        " #{level} "
      end

      def http_method(json)
        json['http.request.method'] || json['http_method']
      end

      def url_path(json)
        json['url.path'] || json['http_path']
      end

      def colorize(text, color_code)
        " \e[#{color_code}m#{text}\e[0m "
      end

      def blue(text)
        colorize(text, '1;30;44')
      end

      def yellow(text)
        colorize(text, '1;30;43')
      end

      def red(text)
        colorize(text, '1;30;41')
      end
    end
  end
end
