module Lapidarist
  class Logger
    def header(message)
      write '', 0
      write "#{message} ...", 0
    end

    def smart_header(message)
      if Lapidarist.config.verbosity > 0
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
      return unless Lapidarist.config.debug

      if label
        puts " DEBUG (#{label}) > #{message}"
      else
        puts " DEBUG > #{message}"
      end
    end

    def std_out_err(message, command)
      write "OUT_ERR (#{command}) > #{message.strip}", 2
    end

    def std_out(message, command)
      write "OUT (#{command}) > #{message.strip}", 2
    end

    def setup
      if Lapidarist.config.log_path && !Lapidarist.config.log_path.empty?
        Open3.capture2("mkdir -p #{Lapidarist.config.log_path.dirname}", chdir: Lapidarist.config.directory)
        Open3.capture2("touch #{Lapidarist.config.log_path}", chdir: Lapidarist.config.directory)
        clear_log_file
      end
    end

    def summary(message)
      write_std_out(message, 0)
      write_log_file(message)
    end

    private

    def write(message, level)
      log_line = "#{' ' * level}#{message}"

      write_std_out(log_line, level)
      write_log_file(log_line)
    end

    def write_std_out(message, level)
      if level <= Lapidarist.config.verbosity && !Lapidarist.config.quiet
        puts message
      end
    end

    def clear_log_file
      Open3.capture2("cp /dev/null #{Lapidarist.config.log_path}", chdir: Lapidarist.config.directory)
    end

    def write_log_file(message)
      if Lapidarist.config.log_path && !Lapidarist.config.log_path.empty?
        Open3.capture2("echo \"#{message}\" >> #{Lapidarist.config.log_path}", chdir: Lapidarist.config.directory)
      end
    end
  end
end
