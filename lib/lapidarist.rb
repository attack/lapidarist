require 'lapidarist/version'
require 'open3'

require_relative 'lapidarist/options'
require_relative 'lapidarist/outdated_gem'

require_relative 'lapidarist/logger'
require_relative 'lapidarist/shell'
require_relative 'lapidarist/bundle_command'
require_relative 'lapidarist/git_command'
require_relative 'lapidarist/test_command'
require_relative 'lapidarist/outdated'
require_relative 'lapidarist/update'

require_relative 'lapidarist/attempt'
require_relative 'lapidarist/progress'
require_relative 'lapidarist/summary'
require_relative 'lapidarist/cli'

module Lapidarist
end
