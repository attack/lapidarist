require 'ostruct'
require 'pathname'

module Lapidarist
  class Configuration < OpenStruct
    def initialize
      super(
        directory: Pathname.new('.'),
        test_script: 'test.sh',
        all: false,
        quiet: false,
        verbosity: 0,
        commit_flags: '',
        debug: false,
        log_path: Pathname.new('./tmp/lapidarist.log'),
        update_limit: nil,
        groups: [],
        version: MAJOR,
        recursive: false,
        random: true,
        seed: nil,
        promoted: [],
        demoted: [],
        only: [],
        except: []
      )
    end
  end
end
