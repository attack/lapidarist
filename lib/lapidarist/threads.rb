module Lapidarist
  class Threads
    def initialize
      @threads = []
      @abort = false
    end

    def <<(thread)
      @threads += Array(thread)
    end

    def stop
      if aborting?
        kill
        exit! STATUS_ERROR
      else
        @abort = true
        abort
      end
    end

    def aborting?
      @abort
    end

    private

    attr_reader :threads

    def alive
      threads.select { |thread| thread.alive? }
    end

    def abort
      alive.each { |thread| Process.kill("INT", thread.pid) }
    end

    def kill
      alive.each { |thread| Process.kill("KILL", thread.pid) }
    end
  end
end
