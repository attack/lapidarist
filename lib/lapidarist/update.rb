module Lapidarist
  class Update
    def initialize(command_class, dependency_class)
      @command = command_class.new
      @dependency_class = dependency_class
      @git = GitCommand.new
    end

    def run(dependencies, attempt)
      before_sha = git.head if Lapidarist.config.debug

      Lapidarist.logger.header('Updating outdated dependencies')

      limit =
        if Lapidarist.config.update_limit
          [Lapidarist.config.update_limit - dependencies.updated.length, 0].max
        else
          dependencies.outdated.length
        end

      updated_dependencies = dependencies.outdated.take(limit).map do |outdated_dependency|
        update_dependency(outdated_dependency, attempt)
      end

      git.log(before_sha) if Lapidarist.config.debug

      updated_dependencies
    end

    private

    attr_reader :outdated_dependencies, :command, :git, :dependency_class

    def update_dependency(outdated_dependency, attempt)
      Lapidarist.logger.smart_header "Updating #{outdated_dependency.name} from #{outdated_dependency.installed_version}"

      level_constraint = Lapidarist::LevelConstraint.new(outdated_dependency)
      command.update(outdated_dependency, level: level_constraint.maximum)
      updated_version = command.version(outdated_dependency)

      if git.clean?
        skipped_dependency = dependency_class.from(outdated_dependency, attempt: attempt, status: :skipped, reason: :nothing_to_update)
        Lapidarist.logger.footer "nothing to update for #{skipped_dependency.name}"

        skipped_dependency
      else
        updated_dependency = dependency_class.from(outdated_dependency, attempt: attempt, status: :updated, updated_version: updated_version)
        Lapidarist.logger.footer "updated #{updated_dependency.name} to #{updated_dependency.updated_version}"

        git.add(*command.files)
        git.commit("Update #{updated_dependency.what_changed}")

        updated_dependency
      end
    end
  end
end
