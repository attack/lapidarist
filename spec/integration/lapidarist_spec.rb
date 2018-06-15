require 'spec_helper'
require 'tmpdir'
require 'open3'
require 'pathname'

RSpec.describe 'Lapidarist CLI', type: :integration do
  describe '# lapidarist' do
    it 'updates each outdated gem dependency in a separate commit' do
      within_temp_repo do |env, bundle, git|
        bundle.add_gem(:rake, '12.3.0', '<= 12.3.1')
        bundle.add_gem(
          :sprockets, '3.7.0', '<= 3.7.1',
          ['concurrent-ruby', '1.0.4', '~> 1.0'],
          ['rack', '2.0.4', '> 1, < 3']
        )
        bundle.add_gem(
          :i18n, '1.0.0', '<= 1.0.1',
          ['concurrent-ruby', '1.0.4', '~> 1.0']
        )
        bundle.install

        bundle.exec("lapidarist #{env.directory}")

        git_commits = git.commit_messages
        expect(git_commits.length).to eq 3
        expect(git_commits).to include "Update rake from 12.3.0 to 12.3.1"
        expect(git_commits).to include "Update sprockets from 3.7.0 to 3.7.1"
        expect(git_commits).to include "Update i18n from 1.0.0 to 1.0.1"
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
    @gems = {}
    @sub_dependencies = {}
  end

  def add_gem(name, version, constraint, *sub_dependencies)
    gem = {
      version: version,
      constraint: constraint,
      sub_dependencies: {}
    }

    sub_dependencies.each do |sub_dependency|
      gem[:sub_dependencies][sub_dependency[0]] = {
        version: sub_dependency[1],
        constraint: sub_dependency[2]
      }
    end

    gems[name] = gem
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

      gems.each do |gem_name, gem_info|
        f.puts "gem '#{gem_name}', '#{gem_info[:constraint]}'"
      end
    end
  end

  def generate_lock
    env.write_file('Gemfile.lock') do |f|
      f.puts 'GEM'
      f.puts '  remote: https://rubygems.org/'
      f.puts '  specs:'

      sub_dependencies = {}
      gems.each do |gem_name, gem_info|
        f.puts "    #{gem_name} (#{gem_info[:version]})"
        gem_info[:sub_dependencies].each do |sub_dependency_name, sub_dependency_info|
          f.puts "      #{sub_dependency_name} (#{sub_dependency_info[:constraint]})"
          sub_dependencies[sub_dependency_name] = sub_dependency_info
        end
      end

      sub_dependencies.each do |gem_name, gem_info|
        f.puts "    #{gem_name} (#{gem_info[:version]})"
      end
    end
  end

  def bundle
    env.run('bundle install')
  end
end
