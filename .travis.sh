#!/bin/bash
set -ev
MODS="$(git diff HEAD~1 Puppetfile | grep "^+" -B2 | grep mod | cut -d"'" -f2)"
rake validate_puppetfile SPEC_OPTS='--format documentation --color --backtrace' || exit 1
if [ "${MODS}" != "" ]; then
  for module in ${MODS}; do
    if [ -e ./${module}/Rakefile ]; then
      rake test_modules[./${module}/Rakefile] SPEC_OPTS='--format documentation --color --backtrace' || exit 1
    else
      echo "Missing ./${module}/Rakefile, not running spec tests. You have to manually check whether this is OK."
      exit 1
    fi
  done
else
  echo "No changed module detected!"
  git diff HEAD~1 Puppetfile
  exit 0
fi
