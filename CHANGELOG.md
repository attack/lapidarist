# Change log

## master (unreleased)

* errors return status of 2 instead of 1
* capture invalid option error, and display message
* capture interrupt and clean up git commits

### Bug fixes

* when the version doesn't change (but dependencies do), do not attempt any more recursive updates

### New features

## 0.1.1 (2018-08-11)

### New features

* add ability to parse and update gems locked to a sha.

### Bug fixes

* fix promoted/demoted bug when gem wasn't in the outdated list.

## 0.1.0 (2018-08-07)

### New features

* by default, outdated gems are updated in random order.
* allow random seed to be provided.
* use CircleCi to run specs.
* allow groups to have different semver level restrictions.
* add ability to promote gems in the order of being updated.
* add ability to demote gems in the order of being updated.
* add ability to only update specific gems.
* add ability to update everything but specific excluded gems.

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
