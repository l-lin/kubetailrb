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
      # naive_read
      read_with_fd
    end

    # NOTE: Is there something like `attr_reader` but for boolean?
    # Nope, Ruby does not know if a variable is a boolean or not. So it cannot
    # create a dedicated method for those booleans.
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
    # Does not support `--follow`.
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

    #
    # Use `seek` to start from the EOF.
    # Use `read` to read the content of the file from the given position.
    # src: https://renehernandez.io/tutorials/implementing-tail-command-in-ruby/
    # Took ~0.13s to read a 3.1G file (5M lines).
    #
    def read_with_fd
      file = File.open(@filepath)
      update_stats file
      read_last_nb_lines file

      if @follow
        begin
          loop do
            if file_changed?(file)
              update_stats(file)
              print file.read
            end
          end
        # Capture Ctrl+c so the program will not display an error in the
        # terminal.
        rescue SignalException
          puts '' # No need to display anything.
        end
      end
    ensure
      file&.close
    end

    def read_last_nb_lines(file)
      return if File.empty?(file)

      pos = 0
      current_line_nb = 0

      loop do
        pos -= 1
        # Seek file position from the end.
        file.seek(pos, IO::SEEK_END)

        # If we have reached the begining of the file, read all the file.
        # We need to do this check before reading the next byte, otherwise, the
        # cursor will be moved to 1.
        break if file.tell.zero?

        # Read only one character (or is it byte?).
        char = file.read(1)
        current_line_nb += 1 if char == "\n"

        break if current_line_nb > @last_nb_lines
      end

      update_stats file
      puts file.read
    end

    def update_stats(file)
      @mtime = file.stat.mtime
      @size = file.size
    end

    def file_changed?(file)
      @mtime != file.stat.mtime || @size != file.size
    end
  end

  # NOTE: We can create custom exceptions by extending RuntimeError.
  class NoSuchFileError < RuntimeError
  end

  # NOTE: Is there a generic error in Ruby that represents this type of error?
  class InvalidArgumentError < RuntimeError
  end
end
