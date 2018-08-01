require 'spec_helper'

RSpec.describe Lapidarist::GitCommand do
  describe '#add' do
    it 'calls git add with the provided files' do
      shell = stub_shell

      Lapidarist::GitCommand.new.add('Gemfile', 'Gemfile.lock')

      expect(shell).to have_received(:run).with('git add Gemfile Gemfile.lock')
    end
  end

  describe '#commit' do
    it 'calls git commit with the provided message' do
      shell = stub_shell
      stub_options(commit_flags: nil)

      Lapidarist::GitCommand.new.commit('commit message')

      expect(shell).to have_received(:run).with('git commit -m \'commit message\'', label: 'git commit')
    end

    context 'when commit flags are provided' do
      it 'calls git commit with the provided flags' do
        shell = stub_shell
        stub_options(commit_flags: '--no-verify')

        Lapidarist::GitCommand.new.commit('commit message')

        expect(shell).to have_received(:run).with('git commit -m \'commit message\' --no-verify', label: 'git commit')
      end
    end
  end
end
