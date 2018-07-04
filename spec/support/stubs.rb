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
        all: true
      }.merge(args)

      unless stub_args[:directory].respond_to?(:dirname)
        stub_args[:directory] = Pathname.new(stub_args[:directory])
      end

      double(Lapidarist::Options, stub_args)
    end

    def stub_gem(name: '')
      Lapidarist::OutdatedGem.new(
        name: name || 'foo gem',
        newest_version: nil,
        current_version: nil
      )
    end

    def stub_bundle_command
      bundle = double(Lapidarist::BundleCommand)
      allow(Lapidarist::BundleCommand).to receive(:new) { bundle }
      bundle
    end

    def stub_gemfile
      gemfile = double(Lapidarist::Gemfile)
      allow(Lapidarist::Gemfile).to receive(:new) { gemfile }
      gemfile
    end

    def stub_outdated(*value)
      outdated = double(Lapidarist::Outdated)
      allow(outdated).to receive(:run).and_return(*value)
      allow(Lapidarist::Outdated).to receive(:new) { outdated }
      outdated
    end

    def stub_update
      update = double(Lapidarist::Update, run: nil)
      allow(Lapidarist::Update).to receive(:new) { update }
      update
    end

    def stub_git
      git = double(Lapidarist::GitCommand, bisect: nil, head: nil, reset_hard: nil, clean?: true)
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
