require 'spec_helper'
require 'tmpdir'
require 'open3'
require 'pathname'
require 'singleton'

RSpec.describe 'Lapidarist CLI', type: :integration do
  describe '# lapidarist' do
    context 'when at least one gem update fails the test' do
      it 'updates each outdated listed gem dependency that passes the test in separate commits' do
        within_temp_repo do |env, bundle, git|
          bundle.add_lapidarist
          git.commit_files('add lapidarist', 'Gemfile', 'Gemfile.lock')

          env.write_file('test.sh', 0755) do |f|
            f.write "#!/usr/bin/env bash\n"
            f.write "! git log --pretty=format:\"%s\" | grep -q 'Update rake'\n"
          end
          git.commit_files('add git bisect test file', 'test.sh')

          bundle.add_gem(
            :i18n, '1.0.0', '<= 1.0.1', nil,
            ['concurrent-ruby', '1.0.4', '~> 1.0']
          )
          bundle.add_gem(
            :sprockets, '3.7.0', '<= 3.7.1', nil,
            ['concurrent-ruby', '1.0.4', '~> 1.0'],
            ['rack', '2.0.4', '> 1, < 3']
          )
          bundle.add_gem(
            :addressable, '2.5.2', '<= 2.5.2', nil,
            ['public_suffix', '3.0.1', '>= 2.0.2, < 4.0']
          )
          bundle.add_gem(:rake, '12.3.0', '<= 12.3.1')
          bundle.install
          git.commit_files('add initial gems', 'Gemfile', 'Gemfile.lock')

          expect {
            bundle.exec("lapidarist -d #{env.directory} -t ./test.sh -q")
          }.to change { git.commit_messages.length }.by(2)
          expect(exit_status).to be_success

          git_commits = git.commit_messages
          expect(git_commits).to include 'Update sprockets from 3.7.0 to 3.7.1'
          expect(git_commits).to include 'Update i18n from 1.0.0 to 1.0.1'
        end
      end

      it 'updates each outdated gem that passes the test in separate commits' do
        within_temp_repo do |env, bundle, git|
          bundle.add_lapidarist
          git.commit_files('add lapidarist', 'Gemfile', 'Gemfile.lock')

          env.write_file('test.sh', 0755) do |f|
            f.write "#!/usr/bin/env bash\n"
            f.write "exit 0\n"
          end
          git.commit_files('add git bisect test file', 'test.sh')

          bundle.add_gem(
            :i18n, '1.0.0', '<= 1.0.1', nil,
            ['concurrent-ruby', '1.0.4', '~> 1.0']
          )
          bundle.add_gem(
            :faraday, '0.12.1', '<= 0.12.2', nil,
            ['multipart-post', '1.2.0', '>= 1.2, < 3']
          )
          bundle.add_gem(
            :addressable, '2.5.2', '<= 2.5.2', nil,
            ['public_suffix', '3.0.1', '>= 2.0.2, < 4.0']
          )
          bundle.install
          git.commit_files('add initial gems', 'Gemfile', 'Gemfile.lock')

          expect {
            bundle.exec("lapidarist -d #{env.directory} -t ./test.sh --all -q --ordered")
          }.to change { git.commit_messages.length }.by(4)
          expect(exit_status).to be_success

          git_commits = git.commit_messages
          expect(git_commits).to include 'Update public_suffix from 3.0.1 to 3.0.3'
          expect(git_commits).to include 'Update concurrent-ruby from 1.0.4 to 1.0.5'
          expect(git_commits).to include 'Update faraday from 0.12.1 to 0.12.2'
          expect(git_commits).to include 'Update i18n from 1.0.0 to 1.0.1'
        end
      end
    end

    context 'when all gem updates pass the test' do
      it 'updates all outdated listed gem dependencies in separate commits' do
        within_temp_repo do |env, bundle, git|
          bundle.add_lapidarist
          git.commit_files('add lapidarist', 'Gemfile', 'Gemfile.lock')

          env.write_file('test.sh', 0755) do |f|
            f.write "#!/usr/bin/env bash\n"
            f.write "exit 0\n"
          end
          git.commit_files('add git bisect test file', 'test.sh')

          bundle.add_gem(
            :i18n, '1.0.0', '<= 1.0.1', nil,
            ['concurrent-ruby', '1.0.4', '~> 1.0']
          )
          bundle.add_gem(
            :sprockets, '3.7.0', '<= 3.7.1', nil,
            ['concurrent-ruby', '1.0.4', '~> 1.0'],
            ['rack', '2.0.4', '> 1, < 3']
          )
          bundle.add_gem(:rake, '12.3.0', '<= 12.3.1')
          bundle.install
          git.commit_files('add initial gems', 'Gemfile', 'Gemfile.lock')

          expect {
            bundle.exec("lapidarist -d #{env.directory} -t ./test.sh -q")
          }.to change { git.commit_messages.length }.by(3)
          expect(exit_status).to be_success

          git_commits = git.commit_messages
          expect(git_commits).to include 'Update sprockets from 3.7.0 to 3.7.1'
          expect(git_commits).to include 'Update rake from 12.3.0 to 12.3.1'
          expect(git_commits).to include 'Update i18n from 1.0.0 to 1.0.1'
        end
      end
    end

    context 'when all gem updates fail the test' do
      it 'does not add any commits' do
        within_temp_repo do |env, bundle, git|
          bundle.add_lapidarist
          git.commit_files('add lapidarist', 'Gemfile', 'Gemfile.lock')

          env.write_file('test.sh', 0755) do |f|
            f.write "#!/usr/bin/env bash\n"
            f.write "exit 1\n"
          end
          git.commit_files('add git bisect test file', 'test.sh')

          bundle.add_gem(:rake, '12.3.0', '<= 12.3.1')
          bundle.install
          git.commit_files('add initial gems', 'Gemfile', 'Gemfile.lock')

          expect {
            bundle.exec("lapidarist -d #{env.directory} -t ./test.sh -q")
          }.not_to change { git.commit_messages.length }
          expect(exit_status).not_to be_success
          expect(exit_status.exitstatus).to eq 1
        end
      end
    end

    context 'when there are no gems to update' do
      it 'does not add any commits' do
        within_temp_repo do |env, bundle, git|
          bundle.add_lapidarist
          git.commit_files('add lapidarist', 'Gemfile', 'Gemfile.lock')

          env.write_file('test.sh', 0755) do |f|
            f.write "#!/usr/bin/env bash\n"
            f.write "exit 0\n"
          end
          git.commit_files('add git bisect test file', 'test.sh')

          bundle.add_gem(:rake, '12.3.0', '<= 12.3.0')
          bundle.install
          git.commit_files('add initial gems', 'Gemfile', 'Gemfile.lock')

          expect {
            bundle.exec("lapidarist -d #{env.directory} -t ./test.sh -q")
          }.not_to change { git.commit_messages.length }
          expect(exit_status).to be_success
        end
      end
    end

    context 'when the number of gems to update is specified' do
      it 'updates only the specified number of gems' do
        within_temp_repo do |env, bundle, git|
          bundle.add_lapidarist
          git.commit_files('add lapidarist', 'Gemfile', 'Gemfile.lock')

          env.write_file('test.sh', 0755) do |f|
            f.write "#!/usr/bin/env bash\n"
            f.write "! git log --pretty=format:\"%s\" | grep -q 'Update i18n'\n"
          end
          git.commit_files('add git bisect test file', 'test.sh')

          bundle.add_gem(
            :i18n, '1.0.0', '<= 1.0.1', nil,
            ['concurrent-ruby', '1.0.4', '~> 1.0']
          )
          bundle.add_gem(
            :sprockets, '3.7.0', '<= 3.7.1', nil,
            ['concurrent-ruby', '1.0.4', '~> 1.0'],
            ['rack', '2.0.4', '> 1, < 3']
          )
          bundle.add_gem(
            :addressable, '2.5.1', '<= 2.5.2', nil,
            ['public_suffix', '2.0.5', '>= 2.0.2, ~> 2.0']
          )
          bundle.add_gem(:rake, '12.3.0', '<= 12.3.1')
          bundle.install
          git.commit_files('add initial gems', 'Gemfile', 'Gemfile.lock')

          expect {
            bundle.exec("lapidarist -d #{env.directory} -t ./test.sh -q -n 2 --ordered")
          }.to change { git.commit_messages.length }.by(2)
          expect(exit_status).to be_success

          git_commits = git.commit_messages
          expect(git_commits).to include 'Update addressable from 2.5.1 to 2.5.2'
          expect(git_commits).to include 'Update rake from 12.3.0 to 12.3.1'
        end
      end
    end

    context 'when the bundler update version is specified' do
      it 'updates only gems respecting the version constraint' do
        within_temp_repo do |env, bundle, git|
          bundle.add_lapidarist
          git.commit_files('add lapidarist', 'Gemfile', 'Gemfile.lock')

          env.write_file('test.sh', 0755) do |f|
            f.write "#!/usr/bin/env bash\n"
            f.write "exit 0\n"
          end
          git.commit_files('add git bisect test file', 'test.sh')

          bundle.add_gem(:"concurrent-ruby", '1.0.4', '<= 1.0.5')
          bundle.add_gem(:httpclient, '2.7.1', '<= 2.8.3')
          bundle.add_gem(:rake, '11.2.0', '<= 12.3.1')
          bundle.add_gem(:rack, '1.6.10', '<= 2.0.5')
          bundle.install
          git.commit_files('add initial gems', 'Gemfile', 'Gemfile.lock')

          expect {
            bundle.exec("lapidarist -d #{env.directory} -t ./test.sh -q --minor")
          }.to change { git.commit_messages.length }.by(3)
          expect(exit_status).to be_success

          git_commits = git.commit_messages
          expect(git_commits).to include 'Update rake from 11.2.0 to 11.3.0'
          expect(git_commits).to include 'Update httpclient from 2.7.1 to 2.8.3'
          expect(git_commits).to include 'Update concurrent-ruby from 1.0.4 to 1.0.5'
        end
      end
    end

    context 'when the bundler group is specified' do
      it 'updates only the specified gems in the group' do
        within_temp_repo do |env, bundle, git|
          bundle.add_lapidarist
          git.commit_files('add lapidarist', 'Gemfile', 'Gemfile.lock')

          env.write_file('test.sh', 0755) do |f|
            f.write "#!/usr/bin/env bash\n"
            f.write "exit 0\n"
          end
          git.commit_files('add git bisect test file', 'test.sh')

          bundle.add_gem(:"concurrent-ruby", '1.0.4', '<= 1.0.5', nil)
          bundle.add_gem(:httpclient, '2.8.2', '<= 2.8.3', :acceptance)
          bundle.add_gem(:rack, '2.0.4', '<= 2.0.5', [:test])
          bundle.add_gem(:rake, '12.3.0', '<= 12.3.1', [:development, :test])
          bundle.install
          git.commit_files('add initial gems', 'Gemfile', 'Gemfile.lock')

          expect {
            bundle.exec("lapidarist -d #{env.directory} -t ./test.sh -q -g test -g acceptance")
          }.to change { git.commit_messages.length }.by(3)
          expect(exit_status).to be_success

          git_commits = git.commit_messages
          expect(git_commits).to include 'Update rake from 12.3.0 to 12.3.1'
          expect(git_commits).to include 'Update rack from 2.0.4 to 2.0.5'
          expect(git_commits).to include 'Update httpclient from 2.8.2 to 2.8.3'
        end
      end
    end

    context 'when the bundler group is specified with version constraints' do
      it 'updates only the specified gems in the group respecting each constraint and the global default' do
        within_temp_repo do |env, bundle, git|
          bundle.add_lapidarist
          git.commit_files('add lapidarist', 'Gemfile', 'Gemfile.lock')

          env.write_file('test.sh', 0755) do |f|
            f.write "#!/usr/bin/env bash\n"
            f.write "exit 0\n"
          end
          git.commit_files('add git bisect test file', 'test.sh')

          bundle.add_gem(:"concurrent-ruby", '1.0.4', '<= 1.0.5', nil)
          bundle.add_gem(:rack, '1.5.4', '<= 2.0.5', [:test])
          bundle.add_gem(:rake, '11.2.0', '<= 12.3.1', [:acceptance, :test])
          bundle.install
          git.commit_files('add initial gems', 'Gemfile', 'Gemfile.lock')

          expect {
            bundle.exec("lapidarist -d #{env.directory} -t ./test.sh -q -g test:minor -g acceptance --patch")
          }.to change { git.commit_messages.length }.by(2)
          expect(exit_status).to be_success

          git_commits = git.commit_messages
          expect(git_commits).to include 'Update rake from 11.2.0 to 11.2.2'
          expect(git_commits).to include 'Update rack from 1.5.4 to 1.6.10'
        end
      end
    end

    context 'when recursion is enabled' do
      it 'updates gems by trying each semver level' do
        within_temp_repo do |env, bundle, git|
          bundle.add_lapidarist
          git.commit_files('add lapidarist', 'Gemfile', 'Gemfile.lock')

          env.write_file('test.sh', 0755) do |f|
            f.write "#!/usr/bin/env bash\n"
            f.write "git log --pretty=format:\"%s\" | grep -q 'Update rake from 11.2.0 to 11.2.2'\n"
          end
          git.commit_files('add git bisect test file', 'test.sh')

          bundle.add_gem(:rake, '11.2.0', '>= 11.2.0')
          bundle.install
          git.commit_files('add initial gems', 'Gemfile', 'Gemfile.lock')

          expect {
            bundle.exec("lapidarist -d #{env.directory} -t ./test.sh -r -q")
          }.to change { git.commit_messages.length }.by(1)
          expect(exit_status).to be_success

          git_commits = git.commit_messages
          expect(git_commits).to include 'Update rake from 11.2.0 to 11.2.2'
        end
      end
    end

    context 'when there are uncommitted changes' do
      it 'exits without updating anything' do
        within_temp_repo do |env, bundle, git|
          bundle.add_lapidarist
          git.commit_files('add lapidarist', 'Gemfile', 'Gemfile.lock')

          env.write_file('test.sh', 0755) do |f|
            f.write "#!/usr/bin/env bash\n"
            f.write "exit 0\n"
          end
          git.commit_files('add git bisect test file', 'test.sh')

          bundle.add_gem(:rake, '12.3.0', '<= 12.3.1')
          bundle.install
          git.commit_files('add initial gems', 'Gemfile', 'Gemfile.lock')

          env.run('echo "gem \'rack\'" >> Gemfile')

          expect {
            bundle.exec("lapidarist -d #{env.directory} -t ./test.sh -q")
          }.not_to change { git.commit_messages.length }
          expect(exit_status).not_to be_success
          expect(exit_status.exitstatus).to eq 2
        end
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

  def exit_status
    raise 'unknown exit status' unless ExitStatus.instance.valid?
    ExitStatus.instance.status
  end
end

class ExitStatus
  include Singleton

  attr_accessor :status

  def valid?
    !status.nil?
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

  def write_file(filename, permissions = 0644)
    open(directory.join(filename), 'w', permissions) do |f|
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
    env.run('git config user.email "lapidarist@example.com"')
    env.run('git config user.name "lapidarist integration"')
  end

  def commit_files(message, *files)
    env.run("git add #{files.join(' ')}")
    env.run("git commit -m '#{message}'")
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

  def add_gem(name, version, constraint, groups = [], *sub_dependencies)
    gem = {
      version: version,
      constraint: constraint,
      groups: Array(groups),
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
    stdout, stderr, status = env.run("bundle exec #{command}")
    unless stderr.empty?
      puts stderr
    end
    unless stdout.empty?
      puts stdout
    end
    ExitStatus.instance.status = status
    [stdout, stderr, status]
  end

  def add_lapidarist
    env.run('bundle add lapidarist')
  end

  private

  attr_reader :env, :gems

  def generate_gemfile
    env.write_file('Gemfile') do |f|
      f.puts "source 'https://rubygems.org'"
      f.puts "gem 'lapidarist', path: '#{env.pwd}'"

      gems.each do |gem_name, gem_info|
        if gem_info[:groups].none?
          f.puts "gem '#{gem_name}', '#{gem_info[:constraint]}'"
        elsif gem_info[:groups].one?
          f.puts "gem '#{gem_name}', '#{gem_info[:constraint]}', group: :#{gem_info[:groups].first}"
        else
          f.puts "gem '#{gem_name}', '#{gem_info[:constraint]}', groups: #{gem_info[:groups]}"
        end
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
          if sub_dependency_info[:constraint]
            f.puts "      #{sub_dependency_name} (#{sub_dependency_info[:constraint]})"
          else
            f.puts "      #{sub_dependency_name}"
          end
          sub_dependencies[sub_dependency_name] = sub_dependency_info
        end
      end

      sub_dependencies.each do |gem_name, gem_info|
        unless gems.keys.include?(gem_name.to_sym)
          f.puts "    #{gem_name} (#{gem_info[:version]})"
        end
      end
    end
  end

  def bundle
    env.run('bundle install')
  end
end
