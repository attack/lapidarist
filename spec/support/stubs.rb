module Lapidarist
  module Stubs
    def stub_shell(value = nil, &block)
      shell = double(Lapidarist::Shell, run: value)
      allow(Lapidarist::Shell).to receive(:new) { shell }

      if value.nil? && block_given?
        expect(shell).to receive(:run).and_yield(block.call)
      end

      shell
    end

    def build_options(args = {})
      stub_args = {
        directory: Pathname.new('/foo'),
        verbosity: 0,
        debug: false,
        log_path: nil,
        commit_flags: nil,
        quiet: true,
        update_limit: nil,
        all: false,
        groups: [],
        version: :major
      }.merge(args)

      unless stub_args[:directory].respond_to?(:dirname)
        stub_args[:directory] = Pathname.new(stub_args[:directory])
      end

      double(Lapidarist::Options, stub_args)
    end

    def stub_gem(name: '')
      Lapidarist::Gem.new(
        name: name || 'foo gem',
        newest_version: nil,
        installed_version: nil
      )
    end

    def stub_outdated_gem(name: '')
      Lapidarist::Gem.new(
        name: name || 'foo gem',
        newest_version: nil,
        installed_version: nil
      )
    end

    def stub_gems(gems = [])
      Lapidarist::Gems.new(gems, build_options)
    end

    def stub_bundle_command
      bundle = double(Lapidarist::BundleCommand)
      allow(Lapidarist::BundleCommand).to receive(:new) { bundle }
      bundle
    end

    def stub_outdated_gems(*value)
      gems = double(Lapidarist::Gems).as_null_object
      allow(gems).to receive(:outdated).and_return(*value)
      outdated = double(Lapidarist::Outdated)
      allow(outdated).to receive(:run).and_return(gems)
      allow(Lapidarist::Outdated).to receive(:new) { outdated }
      gems
    end

    def stub_update(*value)
      update = double(Lapidarist::Update)
      allow(update).to receive(:run).and_return(*value)
      allow(Lapidarist::Update).to receive(:new) { update }
      update
    end

    def stub_git
      git = double(Lapidarist::GitCommand, bisect: nil, head: nil, reset_hard: nil, clean?: true, count_commits: 0)
      allow(Lapidarist::GitCommand).to receive(:new) { git }
      git
    end

    def stub_test_command(success:)
      test_command = double(Lapidarist::TestCommand, success?: success)
      allow(Lapidarist::TestCommand).to receive(:new) { test_command }
      test_command
    end
  end
end

RSpec.configure do |config|
  config.include Lapidarist::Stubs
end
