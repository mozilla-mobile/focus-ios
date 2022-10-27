#!/usr/bin/env bash

#
# This script imports strings into the project. It does this by checking
# out the l10n repository and then running the Localizations tool. That
# tool pre-processes the XLIFF files from the l10n repository and then 
# basically runs xcodebuild -importLocales on those.
#
# The script does not create branches or pull requests so it is best
# to run this on a clean branch. You can then run a git diff to check
# the actual changes and create a new branch and pull request with
# those changes included if it all checks out.
#
# Basic workflow:
#
#  $ tools/import-strings.sh
#  $ git checkout -b string-import-YYMMDD
#  $ git push
#  $ gh pr create # (or manually)
#
# For the bigger picture on string import, export see the wiki.
#
#  https://github.com/mozilla-mobile/focus-ios/wiki/Importing-and-Exporting-Strings
#

# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error when substituting.
# -o pipefail: The return value of a pipeline is the status of the last command to exit with a non-zero status, or zero if no command exited with a non-zero status
# -d: Print shell input lines as they are read.
# -x: Print commands and their arguments as they are executed.
set -euo pipefail

if [ ! -d Blockzilla.xcodeproj ]; then
  echo "[E] Run this script from the project root as tools/import-strings.sh"
  exit 1
fi

echo "[*] Cloning mozilla-l10n/focusios-l10n"
git clone https://github.com/mozilla-l10n/focusios-l10n.git

echo "[*] Cloning mozilla-mobile/LocalizationTools"
rm -rf tools/LocalizationTools
(cd tools && git clone https://github.com/mozilla-mobile/LocalizationTools.git Localizations)

printf "\n\n[*] Building tools/Localizations"
(cd tools/Localizations && swift build)

printf "\n\n[*] Importing Strings - takes a minute. (output in import-strings.log)"
(cd tools/Localizations && swift run LocalizationTools \
  --import \
  --project-path "$PWD/../../Blockzilla.xcodeproj" \
  --l10n-project-path "$PWD/../../focusios-l10n" \
  --client "focus-ios") > import-strings.log 2>&1

printf "\n\n[!] Strings have been imported. You can now create a PR."