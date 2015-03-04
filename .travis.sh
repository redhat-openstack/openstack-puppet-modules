#!/bin/bash
set -ev
MODS="$(git diff HEAD~1 Puppetfile | grep "^+" -B2 | grep mod | cut -d"'" -f2)"
ERRORS=""
PASSES=""
rake validate_puppetfile SPEC_OPTS='--format documentation --color --backtrace' || exit 1
if [ "${MODS}" != "" ]; then
  for module in ${MODS}; do
    if [ -e ./${module}/Rakefile ]; then
      rake test_modules[./${module}/Rakefile] SPEC_OPTS='--format documentation --color --backtrace'
      ret=$?
      if [[ $ret -eq 0 ]]; then
        PASSES="${PASSES}\nPassed spec on module ${module}"
      else
        ERRORS="${ERRORS}\nFailed spec on module ${module}"
      fi
    else
      ERRORS="${ERRORS}\nMissing ./${module}/Rakefile, not running spec tests. You have to manually check whether this is OK."
    fi
  done
else
  echo "No changed module detected!"
  git diff HEAD~1 Puppetfile
  exit 0
fi

echo -e "\e[42m${PASSES}"
if [ "${ERRORS}" != "" ]; then
  echo -e "\e[41m${ERRORS}"
  exit 1
fi
