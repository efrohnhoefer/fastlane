#!/bin/bash --login

# Originally from, http://stackoverflow.com/questions/33041109
# Modified to work in RVM and non RVM environments
#
# Xcode 7 (incl. 7.0.1) seems to have a dependency on the system ruby.
# xcodebuild has issues by using rvm to map to another non-system
# ruby. This script is a fix that allows you call xcodebuild in a
# "safe" rvm environment, but will not (AFAIK) affect the "external"
# rvm setting.
#
# The script is a drop in replacement for your xcodebuild call.
#
#   xcodebuild arg1 ... argn
#
# would become
#
#   path/to/xcbuild-safe.sh arg1 ... argn
#
# -----

which rvm > /dev/null

if [[ $? -eq 0 ]]; then
  echo "RVM detected, forcing to use system ruby"
  # This allows you to use rvm in a script. Otherwise you get a BS
  # error along the lines of "cannot use rvm as function". Jeez.
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

  # Cause rvm to use system ruby. AFAIK, this is effective only for
  # the scope of this script.
  rvm use system

  # rvm doesn't unset itself properly without doing this
  unset RUBYLIB
  unset RUBYOPT
  unset BUNDLE_BIN_PATH
  unset _ORIGINAL_GEM_PATH
  unset BUNDLE_GEMFILE
fi

if which rbenv > /dev/null; then
  echo "rbenv detected, removing env variables"

  # Cause rbenv to use system ruby. Lasts only for the scope of this
  # session which will normally just be this script.
  rbenv shell system

  unset RUBYLIB
  unset RUBYOPT
  unset _ORIGINAL_GEM_PATH
  unset BUNDLE_BIN_PATH
  unset BUNDLE_GEMFILE
  unset GEM_HOME
  unset GEM_PATH
fi

# to help troubleshooting
# env | sort > /tmp/env.wrapper
# rvm info >> /tmp/env.wrapper

set -x          # echoes commands
xcodebuild "$@" # calls xcodebuild with all the arguments passed to this
