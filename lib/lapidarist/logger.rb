module Lapidarist
  class Logger
    def initialize(options)
      @options = options
    end

    def header(message)
      write '', 0
      write "#{message} ...", 0
    end

    def smart_header(message)
      if options.verbosity > 0
        header(message)
      else
        info(message, 0)
      end
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

    def setup
      if options.log_path && !options.log_path.empty?
        Open3.capture2("mkdir -p #{options.log_path.dirname}", chdir: options.directory)
        Open3.capture2("touch #{options.log_path}", chdir: options.directory)
        clear_log_file
      end
    end

    private

    attr_reader :options

    def write(message, level)
      log_line = "#{' ' * level}#{message}"

      write_std_out(log_line, level)
      write_log_file(log_line)
    end

    def write_std_out(message, level)
      if level <= options.verbosity && !options.quiet
        puts message
      end
    end

    def clear_log_file
      Open3.capture2("cp /dev/null #{options.log_path}", chdir: options.directory)
    end

    def write_log_file(message)
      if options.log_path && !options.log_path.empty?
        Open3.capture2("echo \"#{message}\" >> #{options.log_path}", chdir: options.directory)
      end
    end
  end
end
