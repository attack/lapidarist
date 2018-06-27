module Lapidarist
  class GitCommand
    def initialize(options)
      @options = options
      @shell = Shell.new(options)
      @logger = Logger.new(options)
    end

    def head
      shell.run('git rev-parse HEAD')[0].strip
    end

    def add(*files)
      shell.run("git add #{files.join(' ')}")
    end

    def commit(message)
      shell.run("git commit -m '#{message}' #{options.commit_flags}", label: 'git commit')
    end

    def bisect(start_sha, test)
      logger.header('Starting bisect')
      bisect_start(start_sha)
      bisect_run(start_sha, test)
    end

    def log(sha)
      shell.run("git log HEAD...#{sha}^ --no-color --oneline", label: 'git log')
    end

    private

    attr_reader :shell, :options, :logger

    def bisect_start(sha)
      shell.run('git bisect start')
      shell.run('git bisect bad')
      shell.run("git bisect good #{sha}", label: 'git bisect good')
    end

    def bisect_run(start_sha, test)
      failing_gem_name = nil

      shell.run("git bisect run #{test}") do |std_out_err|
        while line = std_out_err.gets
          bisect_step = BisectStep.new(line, shell)

          if bisect_step.failure?
            failing_sha = bisect_step.failing_sha
            failing_gem_name = bisect_step.failing_gem(failing_sha)
            logger.info("... found failing gem update: #{failing_gem_name}")
          end

          if bisect_step.success?
            bisect_reset
            rewind_to_last_good_commit(failing_sha)
          end
        end
      end

      if failing_gem_name && options.debug
        log(start_sha)
      end

      failing_gem_name
    end

    def bisect_reset
      shell.run('git bisect reset')
    end

    def rewind_to_last_good_commit(sha)
      shell.run("git reset --hard #{sha}^")
    end
  end

  class BisectStep
    def initialize(line, shell)
      @line = line
      @shell = shell
    end

    def success?
      line == "bisect run success\n"
    end

    def failure?
      !failing_sha.nil?
    end

    def failing_sha
      sha_regex = Regexp::new("(.*) is the first bad commit\n").match(line)
      unless sha_regex.nil?
        sha_regex[1]
      end
    end

    def failing_gem(sha)
      commit_message = shell.run("git log --format=%s -n 1 #{sha}", label: 'git log')[0]

      sha_regex = Regexp::new('Update (.*) from').match(commit_message)
      unless sha_regex.nil?
        sha_regex[1]
      end
    end

    private

    attr_reader :shell, :line
  end
end
