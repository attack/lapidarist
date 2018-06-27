require 'spec_helper'

RSpec.describe Lapidarist::GitCommand do
  describe '#add' do
    it 'calls git add with the provided files' do
      allow(Open3).to receive(:capture3)
      options = double(Lapidarist::Options, directory: '/foo')

      Lapidarist::GitCommand.new(options).add('Gemfile', 'Gemfile.lock')

      expect(Open3).to have_received(:capture3).with('git add Gemfile Gemfile.lock', chdir: '/foo')
    end
  end

  describe '#commit' do
    it 'calls git commit with the provided message' do
      allow(Open3).to receive(:capture3)
      options = double(Lapidarist::Options, directory: '/foo', commit_flags: nil)

      Lapidarist::GitCommand.new(options).commit('commit message')

      expect(Open3).to have_received(:capture3).with('git commit -m \'commit message\'', chdir: '/foo')
    end

    context 'when commit flags are provided' do
      it 'calls git commit with the provided flags' do
        allow(Open3).to receive(:capture3)
        options = double(Lapidarist::Options, directory: '/foo', commit_flags: '--no-verify')

        Lapidarist::GitCommand.new(options).commit('commit message')

        expect(Open3).to have_received(:capture3).with('git commit -m \'commit message\' --no-verify', chdir: '/foo')
      end
    end
  end
end
