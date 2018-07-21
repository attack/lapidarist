module Lapidarist
  class BundleCommand
    def initialize(options)
      @options = options
      @shell = Shell.new(options)
      @logger = Logger.new(options)
    end

    def outdated
      shell.run('cat Gemfile') if options.debug

      Enumerator.new do |y|
        if options.groups.none?
          _outdated(outdated_command, y)
        else
          options.groups.each do |group|
            _outdated(outdated_command(group: group), y)
            _outdated(outdated_command(group: " #{group}"), y)
          end
        end
      end
    end

    def update(gem)
      shell.run("bundle update #{gem.name}")
    end

    def version(gem)
      stdout = shell.run('bundle list', "grep \" #{gem.name} \"")
      result = stdout.match(/\((?<version>[0-9\.]+)\)/)
      result[:version] if result
    end

    private

    attr_reader :shell, :options, :logger

    def parse_gem_from(line)
      regex = / \* (.*) \(newest (\d[\d\.]*\d)[,\s] installed (\d[\d\.]*\d)[\),\s]/.match line

      unless regex.nil?
        OutdatedGem.new(name: regex[1], newest_version: regex[2], current_version: regex[3])
      end
    end

    def outdated_command(group: nil)
      command = ['bundle outdated', '--strict']
      command << "--group=\"#{group}\"" if group
      command.join(' ')
    end

    def _outdated(command, y)
      shell.run(command) do |std_out_err|
        while line = std_out_err.gets
          logger.std_out_err(line, 'bundle outdated')
          gem = parse_gem_from(line)
          y.yield(gem) if gem
        end
      end
    end
  end
end
