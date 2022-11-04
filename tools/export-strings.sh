#!/usr/bin/env bash

# -E: If set, any trap on ERR is inherited by shell functions, command substitutions, and commands executed in a subshell environment. The ERR trap is normally not inherited in such cases.
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error when substituting.
# -o pipefail: The return value of a pipeline is the status of the last command to exit with a non-zero status, or zero if no command exited with a non-zero status
set -Eeuo pipefail

# shellcheck disable=SC2155
declare -r script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
# shellcheck disable=SC2155
declare -r root_dir=$(cd "${script_dir}/.." &>/dev/null && pwd -P)

[[ "${BASH_VERSINFO[0]}" -ge 4 ]] || {
  cat <<EOF
  #############################################################################
  This script requires bash version 4 or higher in order to support 
  associative arrays. Please upgrade your bash version and try again.

  After installing a new version of bash, you will need to update your
  /private/etc/shells file to include the path to the new bash binary.

  If you are using Homebrew, you can do this by running:

  brew install bash
  echo $(brew --prefix)/bin/bash | sudo tee -a /private/etc/shells

  Then, change your login shell to the updated version found at the bottom of
  /private/etc/shells:

  On a Mac with an Intel processor it would be:

  sudo chpass -s /usr/local/bin/bash $(whoami)

  On a Mac with an Apple Silicon processor it would be:

  sudo chpass -s /opt/homebrew/bin/bash $(whoami)

  You will need to restart your terminal for these changes to take effect, and
  don't forget to make sure your bash bin location is prepended to the 
  beginning of your PATH variable.
  #############################################################################
EOF
  exit 1
}
usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-d] -t

Available options:

-h, --help              Print this help and exit
-v, --verbose           Print script debug info
-d, --dry-run           Read commands but do not execute them
-t, --target-client     The target client to export strings for. Must be 'focus-ios' or 'firefox-ios'
EOF
  exit
}

#######################################
# Cleanup files and directories created by the script.
#
# Cleanup is called by trap on SIGINT, SIGTERM, ERR, and EXIT.
# Globals:
#   temp_dirs: expects an array of directories from either
#              the calling function scope, preferrably main(), or
#              from the global scope
# Arguments:
#   None
#######################################
cleanup() {
  # ignore errors during cleanup to avoid recursively calling itself
  trap - SIGINT SIGTERM ERR EXIT
  declare -n temp_dirs
  temp_dirs=$1
  for dir in "${temp_dirs[@]}"; do
      rm -rf "${root_dir}$dir"
  done
}

# Setup colors for output
setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

#######################################
# Send a message to stderr while interpreting escape sequences
#   and allow for formatting the message with colors.
# Uses the more portable 'printf' command instead of the non-POSIX 
#   compliant 'echo -e'.
# Globals:
#   None
# Arguments:
#   $1: Message to send to stderr
# Outputs:
#   Writes message to stderr
#######################################
msg() {
  printf "%b" "${1-}\n" >&2
}

#######################################
# Send an error message to stderr and exits with a non-zero status.
# Globals:
#   RED
#   NOFORMAT  
# Arguments:
#   $1: Message to send to stderr
#   $2: Custom exit code (optional)
# Outputs:
#   Writes message to stderr and exits with a non-zero status
#######################################
die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "\t${RED}[E] $msg${NOFORMAT}"
  exit "$code"
}

#######################################
# Checks if a command exists and is executable.
# Globals:
#   GREEN
#   YELLOW
#   NOFORMAT
# Arguments:
#   $@: Array of commands to check
# Outputs:
#   Writes message to stderr
#######################################
check_dependencies() {
  declare -n deps
  deps=$1
  msg "${YELLOW}[*] Checking dependencies${NOFORMAT}"
  for dep in "${deps[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
      die "Required dependency $dep is not installed."
    fi
    msg "\t${GREEN}[+] Found $dep installed.${NOFORMAT}"
  done
  msg "\t${PURPLE}[+] All dependencies are installed. Moving on...${NOFORMAT}"
}

#######################################
# Checks if the script running was called from the desired directory.
# Globals:
#   BASH_SOURCE
#   YELLOW
#   GREEN
#   NOFORMAT
# Arguments:
#   $1: The root directory of the project
#   $2: The name of the directory to check
# Outputs:
#   Writes message to stderr
#######################################
check_script_exe_location() {
  declare project_name
  script_name=$(basename "${BASH_SOURCE[0]}")
  project_name=$1
  msg "${YELLOW}[*] Checking if ${script_name} is being called from project root...${NOFORMAT}"
  [[ ! -d "${root_dir}/${project_name}" ]] && die "${script_name} must be run from ${root_dir}"
  msg "\t${GREEN}[+] ${script_name} is running from project root. Moving on...${NOFORMAT}"
}

#######################################
# Checks for the existence of previously created temporary directories
#   and removes them if they exist.
# Globals:
#   YELLOW
#   ORANGE
#   GREEN
#   NOFORMAT
# Arguments:
#   $1: An array of directories to check for
# Outputs:
#   Writes message to stderr
#######################################
check_temp_artifacts() {
  declare temp_dir
  temp_dir="${1}"
  msg "${YELLOW}[*] Checking for temporary artifacts for ${temp_dir}...${NOFORMAT}"
  if [[ -d "${root_dir}${temp_dir}" ]]; then
    msg "\t${ORANGE}Temporary directory ${temp_dir} already exists. Removing now..."
    rm -rf "${root_dir}${temp_dir}" || die "Failed to remove temporary directory ${temp_dir}"
    msg "\t${GREEN}[+] Removed temporary directory ${temp_dir}${NOFORMAT}"
  else 
    msg "\t${GREEN}[+] No temporary artifacts found. Moving on...${NOFORMAT}"
  fi
}

parse_params() {
  # default values for flags and params
  # TODO(JackieJohnson: 2022-11-03): remove 'readonly' and set to empty string
  #   once scripts are unified across firefox-ios and focus-ios
  readonly target_client="focus-ios" 

  msg "${YELLOW}[*] Parsing script parameters${NOFORMAT}"
  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    -d | --dry-run) dry_run ;;
    -t | --target_client)
      target_client="${2-}"
      shift
      ;;
    -?*) die "Invalid Option: $1" ;;
    *) break ;;
    esac
    shift
  done

  # check required params
  [[ -z "${target_client-}" ]] && die "Missing required parameter: target_client"
  if [[ "${target_client}" != "focus-ios" && "${target_client}" != "firefox-ios" ]] ; then
    die "Invalid target_client: ${target_client} \nValid values are: focus-ios or firefox-ios"
  fi  
  msg "\t${GREEN}[+] Paremeter Parsing Complete!${NOFORMAT}"
  return 0
}

# checks for sytax errors in the script
dry_run() {
  msg "${BLUE}Dry run mode. No commands will be executed.${NOFORMAT}"
  set -vn
}

#######################################
# Checks for the existence of previously created temporary directories
#   and removes them if they exist.
# Globals:
#   YELLOW
#   GREEN
#   NOFORMAT
# Arguments:
#   $1: repo name as org/repo
#   $2: destination directory(optional: defaults to current directory)
# Outputs:
#   Writes message to stderr
#######################################
clone_repo() {
  declare -n repo
  repo=$1
  repo_name="${repo[url]##*/}"
  destination="${root_dir}${repo[dir]:-$repo_name}"
  check_temp_artifacts "${repo[dir]}"
  msg "${YELLOW}[*] Cloning https://github.com/${repo[url]}.git...${NOFORMAT}"
  git clone "https://github.com/${repo[url]}.git" "${destination}" >> export-strings.log 2>&1 || die "Failed to clone ${repo_name}"
  msg "\t${GREEN}[+] Cloned https://github.com/${repo[url]}.git into ${destination}${NOFORMAT}"
}

#######################################
# Checks for script dependencies and exits if any are missing.
# Globals:
#   YELLOW
#   PURPLE
#   NOFORMAT
# Arguments:
#   $1: Associative Array with script requirements
# Outputs:
#   Writes message to stderr
#######################################
run_checks() {
  declare -n requirements dirs
  requirements=$1
  dirs="${requirements[tmp_dirs]}"
  msg "${YELLOW}[*] Running checks...${NOFORMAT}"
  for dir in "${dirs[@]}"; do
    check_temp_artifacts "${dir}"
  done
  check_script_exe_location "${requirements[project_dir]}"
  check_dependencies "${requirements[dependencies]}"
  msg "\t${PURPLE}[+] All checks passed. Moving on...${NOFORMAT}"
}

#######################################
# Builds localization import/export script
# Globals:
#   YELLOW
#   GREEN
#   NOFORMAT
# Arguments:
#   $1: Associative Array with localization_tools 
#     git repo and destination directory.
# Outputs:
#   Writes message to stderr
#######################################
build_localization_tools() {
  declare -n localization_tool
  localization_tool=$1
  clone_repo localization_tool
  msg "${YELLOW}[*] Building LocalizationTools...${NOFORMAT}"
  swift build --package-path "${root_dir}${localization_tool[dir]}" >> export-strings.log 2>&1 || die "Failed to build LocalizationTools"
  msg "\t${GREEN}[+] LocalizationTools built successfully. Moving on...${NOFORMAT}"
}

#######################################
# Finds and replaces strings in files using only bash built-ins,
#   pattern matching, and ed to avoid using sed or awk anti-patterns
#   with file editing.
# Globals:
#   root_dir
#   YELLOW
#   GREEN
#   PURPLE
#   NOFORMAT
# Arguments:
#   $1: Associative Array with name of file being editing, the string to
#     find, and the string to replace it with.
# Outputs:
#   Writes message to stderr
#######################################
find_replace_file_text() {
  declare -n file
  declare file_name
  file=$1
  for file in "${file[@]}"; do
  file_name="${file[dir]##*/}"
  msg "${YELLOW}[*] Replacing ${file[find]} with ${file[replace]} in ${file[dir]}...${NOFORMAT}"
  ([[ -f "${root_dir}${file[dir]}" ]] && ed -s "${root_dir}${file[dir]}" <<!
  g/${file[find]}/s//${file[replace]}/g
  w
  q
!
) >> export-strings.log 2>&1 || die "Failed to replace ${file[find]} with ${find[replace]} in ${file_name}"
    msg "\t${GREEN}[+] Replaced ${file[find]} with ${file[replace]} in ${file_name}${NOFORMAT}"
    done
    msg "\t${PURPLE}[+] All file replacements complete. Moving on...${NOFORMAT}"
}

#######################################
# Runs LocalizationTools to export strings from the project.
# Globals:
#   root_dir
#   YELLOW
#   GREEN
#   NOFORMAT
# Arguments:
#   $1: Associative Array with required parameters for LocalizationTools
# Outputs:
#   Writes message to stderr
#######################################
export_strings() {
  declare -n exports lt l10n
  local client
  exports=$1
  lt="${exports[localization_tools]}"
  l10n="${exports[focusios_l10n]}"
  client="${exports[target_client]}"
  clone_repo l10n
  msg "${YELLOW}[*] Exporting strings for ${client}...${NOFORMAT}"
  (cd "${root_dir}${lt[dir]}" && swift run LocalizationTools --export \
    --project-path "${root_dir}/${exports[project_dir]}" \
    --l10n-project-path "${root_dir}${l10n[dir]}") >> export-strings.log 2>&1 || die "Failed to export strings for ${client}"
  msg "${GREEN}[+] Strings exported successfully. Moving on...${NOFORMAT}"
}

# something to show the script isn't frozen during long running tasks
progress_spinner() {
  local pid spinner
  pid=$1
  spinner='- \ | /'
  color=("${GREEN}" "${YELLOW}" "${RED}" "${BLUE}" "${PURPLE}" "${ORANGE}" "${CYAN}" "${NOFORMAT}")
  sleep 1
  while kill -0 "$pid" 2>/dev/null; do
    for i in $spinner; do
      printf "${color[$RANDOM % ${#color[@]}]}%s${NOFORMAT}" "$i$i$i$i$i"
      printf "\b\b\b\b\b"
      sleep 0.25
    done
  done
}

main() {
  trap '$(cleanup ${script_requirements[tmp_dirs]})' SIGINT SIGTERM ERR EXIT
  declare -A localization_tools focusios_l10n tmp_dirs
  declare -A create_templates_task export_task edit_files
  declare dependencies

  dependencies=( git swift ed )

  localization_tools=(
    [url]="mozilla-mobile/LocalizationTools"
    [dir]="/tools/Localizations"
  )

  focusios_l10n=(
    [url]="mozilla-l10n/focusios-l10n"
    [dir]="/focusios-l10n"
  )

  tmp_dirs=(
    [localization_tools]="${localization_tools[dir]}"
    [focusios_l10n]="${focusios_l10n[dir]}"
  )

  create_templates_task=(
    [dir]="${localization_tools[dir]}/Sources/LocalizationTools/tasks/CreateTemplatesTask.swift"
    [find]="firefox-ios.xliff"
    [replace]="focus-ios.xliff"
  )

  export_task=(
    [dir]="${localization_tools[dir]}/Sources/LocalizationTools/tasks/ExportTask.swift"
    [find]="firefox-ios.xliff"
    [replace]="focus-ios.xliff"
  )

  edit_files=(
    [create_templates_task]=create_templates_task
    [export_task]=export_task
  )

  declare -Ar script_requirements=(
    [project_dir]="Blockzilla.xcodeproj"
    [target_client]="focus-ios"
    [dependencies]=dependencies
    [localization_tools]=localization_tools
    [focusios_l10n]=focusios_l10n
    [edit_files]=edit_files
    [tmp_dirs]=tmp_dirs
  )

  parse_params "$@"
  run_checks script_requirements
  build_localization_tools "${script_requirements[localization_tools]}"
  find_replace_file_text "${script_requirements[edit_files]}"
  export_strings script_requirements

  msg "${BLUE}Read parameters:"
  msg "- Client Target: ${target_client}${NOFORMAT}"
  msg "${GREEN}Hooray!! Strings have been succesfully exported."
  msg "You can create a PR in the focusios-l10n checkout.${NOFORMAT}"
  exit
}

setup_colors
main "$@" &
progress_spinner $!