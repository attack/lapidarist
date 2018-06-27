module Lapidarist
  class Shell
    def initialize(options)
      @options = options
      @logger = Logger.new(options)
    end

    def run(*commands, label: nil, &block)
      if commands.one?
        run_single_command(commands.first, label, &block)
      else
        pipe_multiple_commands(*commands, &block)
      end
    end

    private

    attr_reader :options, :logger

    def run_single_command(command, label)
      logger.info "COMMAND > `#{command}`", 1

      if block_given?
        Open3.popen2e(command, chdir: options.directory) do |_std_in, std_out_err|
          yield(std_out_err)
        end
      else
        out_err = []

        status = Open3.popen2e(command, chdir: options.directory) do |_std_in, std_out_err, wait_thr|
          while line = std_out_err.gets
            logger.std_out_err(line, label || command)
            out_err << line
          end
          wait_thr.value
        end

        logger.info "STATUS > #{status}", 2

        [out_err.join("\n"), status]
      end
    end

    def pipe_multiple_commands(*commands)
      if block_given?
        Open3.pipeline_r(*commands, chdir: options.directory) do |std_out, _ts|
          yield(std_out)
        end
      else
        output = ''
        Open3.pipeline_r(*commands, chdir: options.directory) do |std_out, _ts|
          output = std_out.read
        end
        output
      end
    end
  end
end
