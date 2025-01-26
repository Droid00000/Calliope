# frozen_string_literal: true

module Calliope
  # Logs debug messages.
  class Logger
    # @return [true, false] whether this logger is in extra-fancy mode!
    attr_writer :fancy

    # @return [Array<IO>, Array<#puts & #flush>] the streams the logger should write to.
    attr_accessor :streams

    # Creates a new logger.
    # @param fancy [true, false] Whether this logger uses fancy mode (ANSI escape codes to make the output colourful)
    # @param streams [Array<IO>, Array<#puts & #flush>] the streams the logger should write to.
    def initialize(mode, fancy = true, streams = [$stdout])
      @fancy = fancy
      self.mode = :normal
      @streams = streams
    end

    # The modes this logger can have. This is probably useless unless you want to write your own Logger
    MODES = {
      debug: { long: 'DEBUG', short: 'D', format_code: '' },
      good: { long: 'GOOD', short: '✓', format_code: "\u001B[32m" }, # green
      info: { long: 'INFO', short: 'i', format_code: '' },
      warn: { long: 'WARN', short: '!', format_code: "\u001B[33m" }, # yellow
      error: { long: 'ERROR', short: '✗', format_code: "\u001B[31m" }, # red
      out: { long: 'OUT', short: '→', format_code: "\u001B[36m" }, # cyan
      in: { long: 'IN', short: '←', format_code: "\u001B[35m" }, # purple
      ratelimit: { long: 'RATELIMIT', short: 'R', format_code: "\u001B[41m" } # red background
    }.freeze

    # The ANSI format code that resets formatting
    FORMAT_RESET = "\u001B[0m"

    # The ANSI format code that makes something bold
    FORMAT_BOLD = "\u001B[1m"

    MODES.each do |mode, hash|
      define_method(mode) do |message|
        write(message.to_s, hash) if @enabled_modes.include? mode
      end
    end

    # Sets the logging mode
    # Possible modes are:
    #  * :debug logs everything
    #  * :verbose logs everything except for debug messages
    #  * :normal logs useful information, warnings and errors
    #  * :quiet only logs warnings and errors
    #  * :silent logs nothing
    # @param value [Symbol] What logging mode to use
    def mode=(value)
      case value
      when :debug
        @enabled_modes = %i[debug good info warn error out in ratelimit]
      when :verbose
        @enabled_modes = %i[good info warn error out in ratelimit]
      when :normal
        @enabled_modes = %i[info warn error ratelimit]
      when :quiet
        @enabled_modes = %i[warn error]
      when :off
        @enabled_modes = %i[]
      end
    end

    # Logs an exception to the console.
    # @param e [Exception] The exception to log.
    def log_exception(e)
      error("Exception: #{e.inspect}")
      e.backtrace.each { |line| error(line) }
    end

    private

    def write(log, mode)
      @streams.each do |stream|
        if @fancy && !stream.is_a?(File)
          fancy_write(stream, log.to_s, mode, "calliope", Time.now.strftime('%Y-%m-%d %H:%M:%S.%L'))
        else
          simple_write(stream, log.to_s, mode, "calliope", Time.now.strftime('%Y-%m-%d %H:%M:%S.%L'))
        end
      end
    end

    def fancy_write(stream, message, mode, thread_name, timestamp)
      stream.puts "#{timestamp} #{FORMAT_BOLD}#{thread_name.ljust(16)}#{FORMAT_RESET} #{mode[:format_code]}#{mode[:short]}#{FORMAT_RESET} #{message}"
      stream.flush
    end

    def simple_write(stream, message, mode, thread_name, timestamp)
      stream.puts "[#{mode[:long]} : #{thread_name} @ #{timestamp}] #{message}"
      stream.flush
    end
  end
end
