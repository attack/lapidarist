# Change log

## master (unreleased)

### New features

* by default, outdated gems are updated in random order.
* allow random seed to be provided.
* use CircleCi to run specs.
* allow groups to have different semver level restrictions.
* add ability to promote gems in the order of being updated
* add ability to demote gems in the order of being updated
* add ability to only update specific gems
* add ability to update everything but specific excluded gems

## 0.0.1 (2018-08-01)

### New features

* update each outdated gem listed in the Gemfile as a separate git commit.
* allow all gems to be updated, not just those listed in the Gemfile.
* allow git commit command to have additional flags.
* add quiet mode for logging.
* limit the number of gems to be updated.
* do not attempt to update gems if there are uncommitted git changes.
* display summary after all attempts have finished.
* allow the restriction of updates to specific groups.
* restrict updates to a threshold semver level.
* recursively update a gem using each applicable semver level.

### Bug fixes

* go to next update attempt when nothing was updated.
