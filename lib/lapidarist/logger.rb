module Lapidarist
  class Logger
    def initialize(options)
      @options = options
    end

    def header(message)
      write '', 0
      write "#{message} ...", 0
    end

    def footer(message)
      write "... #{message}", 0
    end

    def info(message, level = 0)
      write message, level
    end

    def debug(message, label = nil)
      return unless options.debug

      if label
        puts " DEBUG (#{label}) > #{message}"
      else
        puts " DEBUG > #{message}"
      end
    end

    def std_out_err(message, command)
      write "OUT_ERR (#{command}) > #{message.strip}", 2
    end

    def create_log_file
      Open3.capture2("touch #{options.log_path}", chdir: options.directory)
      clear_log_file
    end

    private

    attr_reader :options

    def write(message, level)
      log_line = "#{' ' * level}#{message}"

      write_std_out(log_line, level)
      write_log_file(log_line)
    end

    def write_std_out(message, level)
      if level <= options.verbosity
        puts message
      end
    end

    def clear_log_file
      Open3.capture2("cp /dev/null #{options.log_path}", chdir: options.directory)
    end

    def write_log_file(message)
      Open3.capture2("echo \"#{message}\" >> #{options.log_path}", chdir: options.directory)
    end
  end
end
