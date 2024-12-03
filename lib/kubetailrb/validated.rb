# frozen_string_literal: true

module Kubetailrb
  # Add behaviors to validate the invariants.
  module Validated
    def raise_if_blank(arg, error_message)
      raise ArgumentError, error_message if arg.nil? || arg.strip&.empty?
    end

    def raise_if_nil(arg, error_message)
      raise ArgumentError, error_message if arg.nil?
    end

    def validate_last_nb_lines(last_nb_lines)
      last_nb_lines_valid = last_nb_lines.is_a?(Integer) && last_nb_lines.positive?
      raise ArgumentError, "Invalid last_nb_lines: #{last_nb_lines}." unless last_nb_lines_valid
    end

    def validate_boolean(follow, error_message)
      raise ArgumentError, error_message unless follow.is_a?(Boolean)
    end
  end
end
