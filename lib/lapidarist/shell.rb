module Lapidarist
  class Shell
    def initialize(options)
      @options = options
    end

    def run(*commands, &block)
      if commands.one?
        run_single_command(commands.first, &block)
      else
        pipe_multiple_commands(*commands, &block)
      end
    end

    private

    attr_reader :options

    def run_single_command(command)
      if block_given?
        Open3.popen2e(command, chdir: options.directory) do |_std_in, std_out_err|
          yield(std_out_err)
        end
      else
        Open3.capture3(command, chdir: options.directory)
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
