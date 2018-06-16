module Lapidarist
  class GitCommand
    def initialize(options)
      @directory = options.directory
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
      bisect_start(start_sha)
      bisect_run(test)
    end

    private

    attr_reader :directory

    def bisect_start(sha)
      Open3.capture3("git bisect start", chdir: directory)
      Open3.capture3("git bisect bad", chdir: directory)
      Open3.capture3("git bisect good #{sha}", chdir: directory)
    end

    def bisect_run(test)
      failing_gem_name = nil

      Open3.popen2e("git bisect run #{test}", chdir: directory) do |_std_in, std_out_err|
        while line = std_out_err.gets
          bisect_step = BisectStep.new(line, directory)

          if bisect_step.failure?
            failing_sha = bisect_step.failing_sha
            failing_gem_name = bisect_step.failing_gem(failing_sha)
          end

          if bisect_step.success?
            bisect_reset
            rewind_to_last_good_commit(failing_sha)
          end
        end
      end

      failing_gem_name
    end

    def bisect_reset
      Open3.capture3('git bisect reset', chdir: directory)
    end

    def rewind_to_last_good_commit(sha)
      Open3.capture3("git reset --hard #{sha}^", chdir: directory)
    end
  end

  class BisectStep
    def initialize(line, directory)
      @line = line
      @directory = directory
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
      commit_message = Open3.capture3("git log --format=%s -n 1 #{sha}", chdir: directory)[0]

      sha_regex = Regexp::new("Update (.*) from").match(commit_message)
      unless sha_regex.nil?
        sha_regex[1]
      end
    end

    private

    attr_reader :directory, :line
  end
end
