require 'spec_helper'
require 'tmpdir'
require 'open3'
require 'pathname'

RSpec.describe 'Lapidarist CLI', type: :integration do
  describe '# lapidarist' do
    it 'updates each outdated gem in a separate commit' do
      within_temp_repo do |env, bundle, git|
        bundle.add_gem(:rake, '12.3.0', '<= 12.3.1')
        bundle.add_gem(:rack, '2.0.3', '<= 2.0.4')
        bundle.install

        bundle.exec("lapidarist #{env.directory}")

        git_commits = git.commit_messages
        expect(git_commits).to include "Update rake from 12.3.0 to 12.3.1"
        expect(git_commits).to include "Update rack from 2.0.3 to 2.0.4"
      end
    end
  end

  def within_temp_repo
    fake_env = FakeEnv.new

    Bundler.with_clean_env do
      bundle = FakeBundle.new(fake_env)
      git = FakeGit.new(fake_env)
      git.init

      yield(fake_env, bundle, git)
    end
  end
end

class FakeEnv
  attr_reader :directory

  def initialize
    @directory = Pathname.new(Dir.mktmpdir('lapidarist'))
  end

  def run(command)
    stdout, stderr, exit_status = Open3.capture3(command, chdir: directory)
    [stdout, stderr, exit_status]
  end

  def write_file(filename)
    open(directory.join(filename), 'w') do |f|
      yield f
    end
  end

  def pwd
    pwd, _, _ = Open3.capture3('pwd')
    pwd.strip
  end
end

class FakeGit
  def initialize(env)
    @env = env
  end

  def init
    env.run('git init')
  end

  def commit_messages
    stdout, _, _ = env.run('git log --pretty=format:"%s"')
    stdout.split("\n")
  end

  private

  attr_reader :env
end

class FakeBundle
  def initialize(env)
    @env = env
    @gems = []
  end

  def add_gem(name, version, constraint)
    gems << {
      name: name,
      version: version,
      constraint: constraint
    }
  end

  def install
    generate_gemfile
    generate_lock
    bundle
  end

  def exec(command)
    stdout, stderr, exit_status = env.run("bundle exec #{command}")
    [stdout, stderr, exit_status]
  end

  private

  attr_reader :env, :gems

  def generate_gemfile
    env.write_file('Gemfile') do |f|
      f.puts "source 'https://rubygems.org'"
      f.puts "gem 'lapidarist', path: '#{env.pwd}'"

      gems.each do |gem|
        f.puts "gem '#{gem[:name]}', '#{gem[:constraint]}'"
      end
    end
  end

  def generate_lock
    env.write_file('Gemfile.lock') do |f|
      f.puts 'GEM'
      f.puts '  remote: https://rubygems.org/'
      f.puts '  specs:'

      gems.each do |gem|
        f.puts "    #{gem[:name]} (#{gem[:version]})"
      end
    end
  end

  def bundle
    env.run('bundle')
  end
end
