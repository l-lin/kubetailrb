# frozen_string_literal: true

module Kubetailrb
  # Read file content
  class FileReader
    attr_reader :filepath, :last_nb_lines

    def initialize(filepath:, last_nb_lines:, follow:)
      @filepath = filepath
      @last_nb_lines = last_nb_lines
      @follow = follow

      validate
    end

    def read
      naive_read
    end

    # NOTE: Is there something like `attr_reader` but for boolean?
    def follow?
      @follow
    end

    private

    def validate
      raise NoSuchFileError, "#{@filepath} not found" unless File.exist?(@filepath)

      last_nb_lines_valid = @last_nb_lines.is_a?(Integer) && @last_nb_lines.positive?

      raise InvalidArgumentError, "Invalid last_nb_lines: #{@last_nb_lines}." unless last_nb_lines_valid

      raise InvalidArgumentError, "Invalid follow: #{@follow}." unless @follow.is_a?(Boolean)
    end

    #
    # Naive implementation to read the last N lines of a file.
    # Took ~1.41s to read a 3.1G file (5M lines).
    #
    def naive_read
      # Let's us `wc` optimized to count the number of lines!
      nb_lines = `wc -l #{@filepath}`.split.first.to_i

      start = nb_lines - @last_nb_lines
      i = 0

      File.open(@filepath, 'r').each_line do |line|
        puts line if i >= start
        i += 1
      end
    end
  end

  # NOTE: We can create custom exceptions by extending RuntimeError.
  class NoSuchFileError < RuntimeError
  end

  # NOTE: Is there a generic error in Ruby that represents this type of error?
  class InvalidArgumentError < RuntimeError
  end
end
