# frozen_string_literal: true

module Kubetailrb
  # Add behaviors to validate the invariants.
  module Validated
    def raise_if_blank(arg, error_message)
      raise InvalidArgumentError, error_message if arg.nil? || arg.strip&.empty?
    end

    def validate_last_nb_lines(last_nb_lines)
      last_nb_lines_valid = last_nb_lines.is_a?(Integer) && last_nb_lines.positive?
      raise InvalidArgumentError, "Invalid last_nb_lines: #{last_nb_lines}." unless last_nb_lines_valid
    end

    def validate_follow(follow)
      raise InvalidArgumentError, "Invalid follow: #{follow}." unless follow.is_a?(Boolean)
    end
  end

  # NOTE: Is there a generic error in Ruby that represents this type of error?
  class InvalidArgumentError < RuntimeError
  end
end
