require "lapidarist/version"
require 'open3'

require_relative 'lapidarist/outdated_gem'
require_relative 'lapidarist/gemfile'

require_relative 'lapidarist/bundle_command'
require_relative 'lapidarist/git_command'

require_relative 'lapidarist/outdated'
require_relative 'lapidarist/update'
require_relative 'lapidarist/cli'

module Lapidarist
end
