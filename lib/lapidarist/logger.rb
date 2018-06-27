module Lapidarist
  class Logger
    def initialize(options)
      @options = options
    end

    def info(message, level = 0)
      if level <= options.verbosity
        puts message
      end
      # system("touch log/bummr.log && echo '#{message}' >> log/bummr.log")
    end

    def std_out_err(message, command, level = 0)
      info "OUT_ERR (#{command}) > #{message}", level
    end

    private

    attr_reader :options
  end
end
