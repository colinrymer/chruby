#!/bin/sh

. ./share/chruby/auto.sh
. ./test/helper.sh

PROJECT_DIR="$PWD/test/project"

setUp()
{
	chruby_reset
	unset RUBY_VERSION_FILE
}

test_chruby_auto_loaded_twice()
{
	. ./share/chruby/auto.sh

	if [[ -n "$ZSH_VERSION" ]]; then
		assertNotEquals "should not add chruby_auto twice" \
			        "$precmd_functions" \
				"chruby_auto chruby_auto"
	else
		assertNotEquals "should not add chruby_auto twice" \
			        "$PROMPT_COMMAND" \
		                "chruby_auto; chruby_auto"
	fi
}

test_chruby_auto_enter_project_dir()
{
	cd "$PROJECT_DIR" && chruby_auto

	assertEquals "did not switch Ruby when entering a versioned directory" \
		     "$TEST_RUBY" "$RUBY"
}

test_chruby_auto_enter_subdir_directly()
{
	cd "$PROJECT_DIR/sub_dir" && chruby_auto

	assertEquals "did not switch Ruby when directly entering a sub-directory of a versioned directory" \
		     "$TEST_RUBY" "$RUBY"
}

test_chruby_auto_enter_subdir()
{
	cd "$PROJECT_DIR" && chruby_auto
	cd sub_dir        && chruby_auto

	assertEquals "did not keep the current Ruby when entering a sub-dir" \
		     "$TEST_RUBY" "$RUBY"
}

test_chruby_auto_enter_subdir_with_ruby_version()
{
	cd "$PROJECT_DIR" && chruby_auto
	cd sub_versioned  && chruby_auto

	assertNull "did not switch the Ruby when leaving a sub-versioned directory" \
		   "$RUBY"
}

test_chruby_auto_overriding_ruby_version()
{
	cd "$PROJECT_DIR" && chruby_auto
	chruby system     && chruby_auto

	assertNull "did not override the Ruby set in .ruby-version" "$RUBY"
}

test_chruby_auto_leave_project_dir()
{
	cd "$PROJECT_DIR" && chruby_auto
	cd sub_dir
	cd ../../..       && chruby_auto

	assertNull "did not reset the Ruby when leaving a versioned directory" \
		   "$RUBY"
}

test_chruby_auto_invalid_ruby_version()
{
	cd "$PROJECT_DIR" && chruby_auto
	cd bad            && chruby_auto 2>/dev/null

	assertEquals "did not keep the current Ruby when loading an unknown version" \
		     "$TEST_RUBY" "$RUBY"
}

SHUNIT_PARENT=$0 . $SHUNIT2
