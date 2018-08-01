module Lapidarist
  class Shell
    def run(*commands, label: nil, &block)
      if commands.one?
        run_single_command(commands.first, label, &block)
      else
        pipe_multiple_commands(*commands, &block)
      end
    end

    private

    def run_single_command(command, label)
      Lapidarist.logger.info "COMMAND > `#{command}`", 1

      if block_given?
        Open3.popen2e(command, chdir: Lapidarist.config.directory) do |_std_in, std_out_err|
          yield(std_out_err)
        end
      else
        out_err = []

        status = Open3.popen2e(command, chdir: Lapidarist.config.directory) do |_std_in, std_out_err, wait_thr|
          while line = std_out_err.gets
            Lapidarist.logger.std_out_err(line, label || command)
            out_err << line
          end
          wait_thr.value
        end

        Lapidarist.logger.info "STATUS > #{status}", 2

        [out_err.join("\n"), status]
      end
    end

    def pipe_multiple_commands(*commands)
      if block_given?
        Open3.pipeline_r(*commands, chdir: Lapidarist.config.directory) do |std_out, _ts|
          yield(std_out)
        end
      else
        output = ''
        Open3.pipeline_r(*commands, chdir: Lapidarist.config.directory) do |std_out, _ts|
          output = std_out.read
        end
        output
      end
    end
  end
end
