require 'spec_helper'

RSpec.describe Lapidarist::CLI do
  describe '#run' do
    context 'when there are is only one outdated gem' do
      context 'and it passes the test' do
        it 'leaves the single commit added by update' do
          stub_outdated_gems(stub_gems([stub_gem]))
          stub_update(stub_gems([stub_gem]))
          stub_test_command(success: true)
          git = stub_git

          Lapidarist::CLI.new(['-q']).run

          expect(git).not_to have_received(:reset_hard).with('HEAD^')
        end
      end

      context 'and it fails the test' do
        it 'removes the single commit added by update' do
          stub_outdated_gems(stub_gems([stub_gem]), stub_gems)
          stub_update(stub_gems([stub_gem]), stub_gems)
          stub_test_command(success: false)
          git = stub_git

          Lapidarist::CLI.new(['-q']).run

          expect(git).to have_received(:reset_hard).with('HEAD^')
        end

        it 'does not run git bisect' do
          stub_outdated_gems(stub_gems([stub_gem]), stub_gems)
          stub_update(stub_gems([stub_gem]), stub_gems)
          stub_test_command(success: false)
          git = stub_git

          Lapidarist::CLI.new(['-q']).run

          expect(git).not_to have_received(:bisect)
        end
      end
    end

    context 'when there are multiple outdated gems' do
      context 'and they fail the test' do
        it 'runs git bisect' do
          stub_outdated_gems(stub_gems([stub_gem, stub_gem]), stub_gems)
          stub_update(stub_gems([stub_gem, stub_gem]))
          stub_test_command(success: false)
          git = stub_git

          Lapidarist::CLI.new(['-q']).run

          expect(git).to have_received(:bisect)
        end
      end
    end
  end
end
