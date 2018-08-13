require 'lapidarist/version'
require 'open3'

require_relative 'lapidarist/configuration'
require_relative 'lapidarist/group_constraint'
require_relative 'lapidarist/level_constraint'
require_relative 'lapidarist/options'
require_relative 'lapidarist/level'
require_relative 'lapidarist/version_change'
require_relative 'lapidarist/gem_version'
require_relative 'lapidarist/gem'
require_relative 'lapidarist/gems'

require_relative 'lapidarist/logger'
require_relative 'lapidarist/shell'
require_relative 'lapidarist/bundle_command'
require_relative 'lapidarist/git_command'
require_relative 'lapidarist/test_command'
require_relative 'lapidarist/update'
require_relative 'lapidarist/outdated'
require_relative 'lapidarist/sha'
require_relative 'lapidarist/find_failure'

require_relative 'lapidarist/threads'
require_relative 'lapidarist/summary'
require_relative 'lapidarist/status'
require_relative 'lapidarist/cli'

module Lapidarist
  STATUS_SUCCESS = 0
  STATUS_FAILED = 1
  STATUS_ERROR = 2

  class Abort < StandardError; end

  class << self
    def config
      @config ||= Lapidarist::Configuration.new
    end

    def logger
      @logger ||= Lapidarist::Logger.new.tap { |l| l.setup }
    end

    def threads
      @threads ||= Lapidarist::Threads.new
    end
  end
end
