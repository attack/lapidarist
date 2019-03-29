module Lapidarist
  class GitCommand
    def initialize
      @shell = Shell.new
    end

    def head
      shell.run('git rev-parse HEAD')[0].strip
    end

    def add(*files)
      shell.run("git add #{files.join(' ')}")
    end

    def commit(message)
      shell.run("git commit -m '#{message}' #{Lapidarist.config.commit_flags}".strip, label: 'git commit')
    end

    def bisect(start_sha, test)
      Lapidarist.logger.header('Starting bisect')
      bisect_start(start_sha)
      bisect_run(start_sha, test)
    end

    def log(sha)
      shell.run("git log HEAD...#{sha}^ --no-color --oneline", label: 'git log')
    end

    def reset_hard(ref)
      shell.run("git reset --hard #{ref}")
    end

    def clean?
      shell.run('[ -z "$(git status --porcelain=v1 -uno)" ]')[1] == 0
    end

    def count_commits(start_sha, end_sha)
      shell.run("git rev-list #{end_sha} ^#{start_sha} --count")[0].to_i
    end

    private

    attr_reader :shell

    def bisect_start(sha)
      shell.run('git bisect start')
      shell.run('git bisect bad')
      shell.run("git bisect good #{sha}", label: 'git bisect good')
    end

    def bisect_run(start_sha, test)
      failing_dependency_name = nil

      shell.run("git bisect run '#{test}'") do |std_out_err|
        while line = std_out_err.gets
          bisect_step = BisectStep.new(line, shell)

          if bisect_step.failure?
            failing_sha = bisect_step.failing_sha
            failing_dependency_name = bisect_step.failing_dependency(failing_sha)
            Lapidarist.logger.info("... found failing dependency update: #{failing_dependency_name}")
          end

          if bisect_step.success?
            bisect_reset
            rewind_to_last_good_commit(failing_sha)
          end
        end

        unless failing_dependency_name
          Lapidarist.logger.info("... last commit was failing commit")
        end

        Lapidarist.logger.footer("bisect done")
      end

      if failing_dependency_name && Lapidarist.config.debug
        log(start_sha)
      end

      failing_dependency_name
    end

    def bisect_reset
      shell.run('git bisect reset')
    end

    def rewind_to_last_good_commit(sha)
      reset_hard("#{sha}^")
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

    def failing_dependency(sha)
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
