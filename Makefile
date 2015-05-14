# NOTE: in this file tab indentation is used.
# Otherwise .RECIPEPREFIX would have to be set.


# ==============================================================================
# create variables
# ==============================================================================

# _________________
# general variables
#

extension_name := rpcontinued
extension_uuid := rpcontinued@requestpolicy.org

# ____________________________________
# generating XPIs -- general variables
#

# The zip application to be used.
ZIP := zip

source_dirname := src
build_dirname := build
dist_dirname := dist

source_path := $(source_dirname)/
dist_path := $(dist_dirname)/


# collect files that are part of the source code
source_files := $(shell find $(source_dirname) -type f -regex ".*\.jsm?") \
		$(source_dirname)/chrome.manifest \
		$(source_dirname)/install.rdf \
		$(source_dirname)/README \
		$(wildcard $(source_dirname)/content/settings/*.css) \
		$(wildcard $(source_dirname)/content/settings/*.html) \
		$(wildcard $(source_dirname)/content/ui/*.xul) \
		$(wildcard $(source_dirname)/locale/*/*.dtd) \
		$(wildcard $(source_dirname)/locale/*/*.properties) \
		$(wildcard $(source_dirname)/skin/*.css) \
		$(wildcard $(source_dirname)/skin/*.png) \
		$(wildcard $(source_dirname)/skin/*.svg)

# files that are in the root of the repository
root_files := LICENSE


# ____________________________________
# vars for generating the "normal" XPI
#

build_path := $(build_dirname)/normal/

xpi_file := $(dist_path)$(extension_name).xpi

# take all source files from above and replace the source path by the build path
normal_build__src_files := $(patsubst $(source_path)%,$(build_path)%,$(source_files))

javascript_files := $(filter %.js %.jsm,$(normal_build__src_files))
other_files := $(filter-out $(javascript_files),$(normal_build__src_files))

normal_build__root_files := $(addprefix $(build_path),$(root_files))

all_files := $(normal_build__src_files) $(normal_build__root_files)


# detect deleted files and empty directories
deleted_files :=
empty_dirs :=
ifneq "$(wildcard $(build_path))" ""
# files that have been deleted but still exist in the build directory.
deleted_files := $(shell find $(build_path) -type f | \
		grep -v "META-INF" | \
		grep -F -v $(addprefix -e ,$(all_files)))
# empty directories. -mindepth 1 to exclude the build directory itself.
empty_dirs := $(shell find $(build_path) -mindepth 1 -type d -empty)
endif


# ________________________________
# vars for generating a signed XPI
#

signed_xpi_file := $(dist_path)$(extension_name)-signed.xpi


# ________________________________________
# vars for generating the unit-testing XPI
#

unit_testing__build_path := $(build_dirname)/unit-testing/

unit_testing__xpi_file := $(dist_path)$(extension_name)-unit-testing.xpi

# take all files from above and create their paths in the "build" directory
unit_testing__src_files := $(patsubst $(source_path)%,$(unit_testing__build_path)%,$(source_files))

unit_testing__javascript_files := $(filter %.js %.jsm,$(unit_testing__src_files))
unit_testing__other_files := $(filter-out $(unit_testing__javascript_files),$(unit_testing__src_files))

unit_testing__root_files := $(addprefix $(unit_testing__build_path),$(root_files))

unit_testing__all_files := $(unit_testing__src_files) $(unit_testing__root_files)


# detect deleted files and empty directories
unit_testing__deleted_files :=
unit_testing__empty_dirs :=
ifneq "$(wildcard $(unit_testing__build_path))" ""
# files that have been deleted but still exist in the build directory.
unit_testing__deleted_files := \
		$(shell find $(unit_testing__build_path) -type f | \
		grep -v "META-INF" | \
		grep -F -v $(addprefix -e ,$(unit_testing__all_files)))
# empty directories. -mindepth 1 to exclude the build directory itself.
unit_testing__empty_dirs := $(shell find $(unit_testing__build_path) -mindepth 1 -type d -empty)
endif


# ______________________________________
# vars for generating the Dev Helper XPI
#

dev_helper__source_dirname := tests/mozmill/extension
dev_helper__source_path := $(dev_helper__source_dirname)/

dev_helper__source_files := $(shell find $(dev_helper__source_dirname) -type f -regex ".*\.jsm?") \
		$(dev_helper__source_dirname)/chrome.manifest \
		$(dev_helper__source_dirname)/install.rdf

dev_helper__xpi_file := $(dist_path)rpc-dev-helper.xpi


# ______________________________
# vars for mozrunner and mozmill
#

# the default XPI to use for mozrunner and mozmill
moz_xpi := $(unit_testing__xpi_file)

# select the default app. Can be overridden e.g. via `make run app='seamonkey'`
app := firefox
# default app branch
ifeq ($(app),firefox)
app_branch := nightly
else
app_branch := release
endif
binary_filename := $(app)
app_binary := .mozilla/software/$(app)/$(app_branch)/$(binary_filename)

# __________________
# vars for mozrunner
#

mozrunner_prefs_ini := tests/mozrunner-prefs.ini



# ==============================================================================
# define targets
# ==============================================================================

.PHONY: all build dist sign

# set "all" to be the default target
.DEFAULT_GOAL := all

# building means to prepare all files in the build directory
build: $(build_path)

# build and create XPI file
all: $(xpi_file)
	@echo "Build finished successfully."
dist: $(xpi_file)

# create the dist directory
$(dist_path):
	@mkdir -p $(dist_path)

sign: $(signed_xpi_file)


# _______________________
# create the "normal" XPI
#

# Note: Here the build path is added as a prerequisite, *not* the
#       phony "build" target. This avoids re-packaging in case
#       nothing has changed.
#       Also $(all_files) is needed as prerequisite, so that the
#       xpi gets updated.
$(xpi_file): $(build_path) $(all_files) | $(dist_path)
	@rm -f $(xpi_file)
	@echo "Creating XPI file."
	@cd $(build_path) && \
	$(ZIP) $(abspath $(xpi_file)) $(patsubst $(build_path)%,%,$(all_files))
	@echo "Creating XPI file: Done!"

# _____________________
# create the signed XPI
#

$(signed_xpi_file): $(build_path)/META-INF/ | $(dist_path)
	@rm -f $(signed_xpi_file)
	@cd $(build_path) && \
	$(ZIP) $(abspath $(signed_xpi_file)) \
		META-INF/zigbert.rsa && \
	$(ZIP) -r -D $(abspath $(signed_xpi_file)) \
		$(patsubst $(build_path)%,%,$(all_files)) META-INF \
		-x META-INF/zigbert.rsa


# ___________________________
# create the unit-testing XPI
#

$(unit_testing__xpi_file): $(unit_testing__build_path) $(unit_testing__all_files) | $(dist_path)
	@rm -f $(unit_testing__xpi_file)
	@echo "Creating unit-testing XPI."
	@cd $(unit_testing__build_path) && \
	$(ZIP) $(abspath $(unit_testing__xpi_file)) $(patsubst $(unit_testing__build_path)%,%,$(unit_testing__all_files))
	@echo "Creating unit-testing XPI: Done!"


# _________________________
# create the Dev Helper XPI
#

# For now use FORCE, i.e. create the XPI every time. If the
# 'FORCE' should be removed, deleted files have to be detected,
# just like for the other XPIs.
$(dev_helper__xpi_file): $(dev_helper__source_files) FORCE | $(dist_path)
	@rm -f $(dev_helper__xpi_file)
	@echo "Creating 'RPC Dev Helper' XPI."
	@cd $(dev_helper__source_dirname) && \
	$(ZIP) $(abspath $(dev_helper__xpi_file)) $(patsubst $(dev_helper__source_path)%,%,$(dev_helper__source_files))
	@echo "Creating 'RPC Dev Helper' XPI: Done!"

# _____________________________________
# create the files for the "normal" XPI
#

# Process all source files, but also eventually delete
# empty directories and deleted files from the build directory.
$(build_path): $(all_files) $(deleted_files) $(empty_dirs)

# enable Secondary Expansion (so that $@ can be used in prerequisites via $$@)
.SECONDEXPANSION:

$(javascript_files): $$(patsubst $$(build_path)%,$$(source_path)%,$$@)
	@mkdir -p $(dir $@)
	preprocess $(patsubst $(build_path)%,$(source_path)%,$@) > $@

$(other_files): $$(patsubst $$(build_path)%,$$(source_path)%,$$@)
	@mkdir -p $(dir $@)
	cp $(patsubst $(build_path)%,$(source_path)%,$@) $@

$(normal_build__root_files): $$(patsubst $$(build_path)%,%,$$@)
	cp $(patsubst $(build_path)%,%,$@) $@

# ___________________________________
# create the files for the signed XPI
#

$(build_path)/META-INF/: $(build_path) $(all_files)
	mkdir -p $(build_path)/META-INF
	signtool -d .signing \
		-k "Open Source Developer, Martin Kimmerle's Unizeto Technologies S.A. ID" \
		$(build_path)

# _________________________________________
# create the files for the unit-testing XPI
#

$(unit_testing__build_path): $(unit_testing__all_files) $(unit_testing__deleted_files) $(unit_testing__empty_dirs)

$(unit_testing__javascript_files): $$(patsubst $$(unit_testing__build_path)%,$$(source_path)%,$$@)
	@mkdir -p $(dir $@)
	preprocess $(patsubst $(unit_testing__build_path)%,$(source_path)%,$@) -UNIT_TESTING=true > $@

$(unit_testing__other_files): $$(patsubst $$(unit_testing__build_path)%,$$(source_path)%,$$@)
	@mkdir -p $(dir $@)
	cp $(patsubst $(unit_testing__build_path)%,$(source_path)%,$@) $@

$(unit_testing__root_files): $$(patsubst $$(unit_testing__build_path)%,%,$$@)
	cp $(patsubst $(unit_testing__build_path)%,%,$@) $@


# __________________
# "cleaning" targets
#

# This cleans all temporary files and directories created by 'make'.
.PHONY: clean
clean:
	@rm -rf $(xpi_file) $(unit_testing__xpi_file) $(build_dirname)/*
	@echo "Cleanup is done."

# remove empty directories
$(empty_dirs): FORCE
	rmdir $@

# delete deleted files that still exist in the build directory.
# this target should be forced
$(deleted_files): FORCE
	@# delete:
	rm $@
	@# delete parent dirs if empty:
	@rmdir --parents --ignore-fail-on-non-empty $(dir $@)

# ___________
# run firefox
#

# arguments for mozrunner
mozrunner_args := -a $(moz_xpi) -a $(dev_helper__xpi_file)
mozrunner_args += -b $(app_binary)
mozrunner_args += --preferences=$(mozrunner_prefs_ini):dev
mozrunner_args += $(moz_args)

.PHONY: run
run: $(moz_xpi) $(dev_helper__xpi_file)
	mozrunner $(mozrunner_args)


# ____________
# unit testing
#

# Note: currently you have to do some setup before this will work.
# see https://github.com/RequestPolicyContinued/requestpolicy/wiki/Setting-up-a-development-environment#unit-tests-for-requestpolicy

mozmill_tests_dir := .mozilla/mozmill-tests
mozmill_rpc_test_dir := $(mozmill_tests_dir)/firefox/tests/addons/$(extension_uuid)

# Default mozmill manifest to use for testing
mm_manifest := manifest.ini

.PHONY: check test mozmill
check test: mozmill

mozmill: $(moz_xpi) $(dev_helper__xpi_file) mozmill-dirs
	mozmill -a $(moz_xpi) -a $(dev_helper__xpi_file) -b $(app_binary) \
		-m $(mozmill_rpc_test_dir)/$(mm_manifest) $(moz_args)



.PHONY: mozmill-dirs
mozmill-dirs: $(mozmill_tests_dir) \
	$(mozmill_rpc_test_dir) \
	$(mozmill_rpc_test_dir)/mozmill-tests \
	$(mozmill_rpc_test_dir)/data

$(mozmill_rpc_test_dir): $(mozmill_tests_dir)
	@test -L $@ \
	|| ln -ns ../../../../../tests/mozmill $@

$(mozmill_rpc_test_dir)/mozmill-tests: $(mozmill_rpc_test_dir)
	@test -L tests/mozmill/mozmill-tests \
	|| ln -ns ../../$(mozmill_tests_dir) tests/mozmill/mozmill-tests

$(mozmill_rpc_test_dir)/data: $(mozmill_rpc_test_dir)
	@test -L tests/mozmill/data \
	|| ln -ns ../../ tests/mozmill/data


# ________________
# "helper" targets
#

.PHONY: FORCE
FORCE:
