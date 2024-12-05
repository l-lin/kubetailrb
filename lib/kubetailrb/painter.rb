# frozen_string_literal: true

module Kubetailrb
  # Add behaviors to colorize console output.
  module Painter
    def blue(text)
      colorize(text, '34')
    end

    def red(text)
      colorize(text, '31')
    end

    def highlight_blue(text)
      colorize(text, '1;30;44')
    end

    def highlight_yellow(text)
      colorize(text, '1;30;43')
    end

    def highlight_red(text)
      colorize(text, '1;30;41')
    end

    private

    def colorize(text, color_code)
      "\e[#{color_code}m#{text}\e[0m"
    end
  end
end
