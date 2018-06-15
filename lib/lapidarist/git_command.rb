module Lapidarist
  class GitCommand
    def initialize(directory)
      @directory = directory
    end

    def head
      Open3.capture3('git rev-parse HEAD', chdir: directory)[0]
    end

    def add(*files)
      Open3.capture3("git add #{files.join(' ')}", chdir: directory)
    end

    def commit(message)
      Open3.capture3("git commit -m '#{message}'", chdir: directory)
    end

    def bisect(start_sha, test)
      bisect_start
      bisect_bad
      bisect_good(start_sha)
      bisect_run(test)
    end

    private

    attr_reader :directory

    def bisect_start
      Open3.capture3('git bisect start', chdir: directory)
    end

    def bisect_bad
      Open3.capture3('git bisect bad', chdir: directory)
    end

    def bisect_good(sha)
      Open3.capture3("git bisect good #{sha}", chdir: directory)
    end

    def bisect_run(test)
      Open3.popen2e("git bisect run #{test}", chdir: directory) do |_std_in, std_out_err|
        while line = std_out_err.gets
          bisect_step = BisectStep.new(line)

          if bisect_step.failure?
            bad_sha = bisect_step.bad_sha
          end

          if bisect_step.success?
            bisect_reset
            remove_to_commit(bad_sha)
          end
        end
      end
    end

    def bisect_reset
      Open3.capture3('git bisect reset', chdir: directory)
    end

    def remove_to_commit(sha)
      Open3.capture3('git checkout .', chdir: directory)
      Open3.capture3("git rebase -p --onto #{sha}^ #{sha}", chdir: directory)
    end
  end

  class BisectStep
    def initialize(line)
      @line = line
    end

    def success?
      line == "bisect run success\n"
    end

    def failure?
      !bad_sha.nil?
    end

    def bad_sha
      sha_regex = Regexp::new("(.*) is the first bad commit\n").match(line)
      unless sha_regex.nil?
        sha_regex[1]
      end
    end

    private

    attr_reader :line
  end
end
