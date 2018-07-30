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
        shell.run('bundle outdated --strict') do |std_out_err|
          while line = std_out_err.gets
            logger.std_out_err(line, 'bundle outdated')
            gem = parse_gem_from(line)
            y.yield(gem) if gem
          end
        end
      end
    end

    def update(gem, level: MAJOR)
      shell.run("bundle update #{gem.name} --strict --#{level.to_s}")
    end

    def version(gem)
      stdout = shell.run('bundle list', "grep \" #{gem.name} \"")
      result = stdout.match(/\((?<version>[0-9\.]+)\)/)
      result[:version] if result
    end

    private

    attr_reader :shell, :options, :logger

    def parse_gem_from(line)
      regex = / \* (.*) \(newest (\d[\d\.]*\d)[,\s] installed (\d[\d\.]*\d)[\),\s](.*groups \"(.*)\")?/.match line

      unless regex.nil?
        Gem.new(
          name: regex[1],
          newest_version: regex[2],
          installed_version: regex[3],
          groups: Array(regex[5]&.split(',')).map(&:strip)
        )
      end
    end
  end
end
