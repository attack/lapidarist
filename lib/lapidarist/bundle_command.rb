module Lapidarist
  class BundleCommand
    def initialize
      @shell = Shell.new
    end

    def outdated
      shell.run('cat Gemfile') if Lapidarist.config.debug

      Enumerator.new do |y|
        shell.run('bundle outdated --strict') do |std_out_err|
          while line = std_out_err.gets
            Lapidarist.logger.std_out_err(line, 'bundle outdated')
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
      result = stdout.match(/\((?<version>[0-9\.]+)(?<sha> \w{7})?\)/)
      Lapidarist::GemVersion.new(version: result[:version], sha: result[:sha]&.strip) if result
    end

    def files
      ['Gemfile', 'Gemfile.lock']
    end

    private

    attr_reader :shell

    def parse_gem_from(line)
      regex = / \* (.*) \(newest (\d[\d\.]*\d)( \w{7})?[,\s] installed (\d[\d\.]*\d)( \w{7})?[\),\s](.*groups \"(.*)\")?/.match line

      unless regex.nil?
        Gem.new(
          name: regex[1],
          newest_version: Lapidarist::GemVersion.new(version: regex[2], sha: regex[3]&.strip),
          installed_version: Lapidarist::GemVersion.new(version: regex[4], sha: regex[5]&.strip),
          groups: Array(regex[7]&.split(',')).map(&:strip)
        )
      end
    end
  end
end
