module Lapidarist
  class BundleCommand
    def initialize(options)
      @options = options
      @shell = Shell.new(options)
      @logger = Logger.new(options)
    end

    def outdated
      if options.debug
        shell.run('cat Gemfile') # do |std_out_err|
          # while line = std_out_err.gets
          #   logger.std_out_err(line, 'Gemfile')
          # end
        # end
      end

      Enumerator.new do |y|
        shell.run('bundle outdated --strict') do |std_out_err|
          while line = std_out_err.gets
            logger.std_out_err(line, 'bundle outdated')
            gem = parse_gem_from(line)
            y.yield(gem) if gem
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
  end
end
