#!/usr/bin/env bash

# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error when substituting.
# -o pipefail: The return value of a pipeline is the status of the last command to exit with a non-zero status, or zero if no command exited with a non-zero status
# -d: Print shell input lines as they are read.
# -x: Print commands and their arguments as they are executed.
set -euo pipefail

if [ ! -d Blockzilla.xcodeproj ]; then
  echo "[E] Run this script from the project root as tools/export-strings.sh"
  exit 1
fi

if [ -d "focusios-l10n" ]; then
echo "Focus iOS L10 directory found. Removing to re-clone for fresh start."
rm -Rf focusios-l10n;
fi

echo "[*] Cloning mozilla-l10n/focusios-l10n"
git clone https://github.com/mozilla-l10n/focusios-l10n.git focusios-l10n

echo "[*] Cloning mozilla-mobile/LocalizationTools"
rm -rf tools/Localizations
(cd tools && git clone https://github.com/mozilla-mobile/LocalizationTools.git Localizations)

printf "\n\n[*] Building tools/Localizations"
(cd tools/Localizations && swift build)

# Temporary workaround to replace firefox-ios with focus-ios in the Localizations tool
printf "\n\n[*] Replacing Swift Tasks Firefox Target with Focus Target"
(gsed -i 's/firefox/focus/g' tools/Localizations/Sources/LocalizationTools/tasks/*.swift)

printf "\n\n[*] Exporting Strings (output in export-strings.log)"
(cd tools/Localizations && swift run LocalizationTools \
  --export \
  --project-path "$PWD/../../Blockzilla.xcodeproj" \
  --l10n-project-path "$PWD/../../focusios-l10n") > export-strings.log 2>&1

printf "\n\n[!] Hooray strings have been succesfully exported."
echo "[!] You can create a PR in the focusios-l10n checkout"