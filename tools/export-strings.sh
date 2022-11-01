#!/usr/bin/env bash

# -E: If set, any trap on ERR is inherited by shell functions, command substitutions, and commands executed in a subshell environment. The ERR trap is normally not inherited in such cases.
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error when substituting.
# -o pipefail: The return value of a pipeline is the status of the last command to exit with a non-zero status, or zero if no command exited with a non-zero status
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-d] -p param_value arg1 [arg2...]

Script description here.

Available options:

-h, --help              Print this help and exit
-v, --verbose           Print script debug info
-d, --dry-run           Read commands but do not execute them
-t, --target-client     The target client to export strings for. Must be 'focus-ios' or 'firefox-ios'
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  for dir in "${tmp_dirs[@]}"; do
      rm -rf "$dir"
  done
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "\t${RED}[E] $msg${NOFORMAT}"
  exit "$code"
}

check_dependencies() {
  local deps
  deps=("$@")
  msg "${YELLOW}[*] Checking dependencies${NOFORMAT}"
  for dep in "${deps[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
      die "Required dependency $dep is not installed."
    fi
  done
  msg "\t${GREEN}[+] Dependencies are installed${NOFORMAT}"
}

check_script_location() {
  local script_name
  script_name=$(basename "${BASH_SOURCE[0]}")
  msg "${YELLOW}[*] Checking if ${script_name} is being called from project root...${NOFORMAT}"
  [[ ! -d Blockzilla.xcodeproj ]] && die "Run this script from ${root_dir} as tools/export-strings.sh"
  msg "\t${GREEN}[+] import-strings is running from project root. Moving on...${NOFORMAT}"
}

check_temp_artifacts() {
  local tmp_dirs
  tmp_dirs=("$@")
  msg "${YELLOW}[*] Checking for temporary artifacts...${NOFORMAT}"
  for dir in "${tmp_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
      msg "\t${ORANGE}Temporary directory $dir already exists. Removing now..."
      rm -rf "$dir" || die "Failed to remove temporary directory $dir"
      msg "\t${GREEN}[+] Removed temporary directory $dir${NOFORMAT}"
    fi
  done
  msg "\t${GREEN}[+] No temporary artifacts found. Moving on...${NOFORMAT}"
}

parse_params() {
  local tmp_default_client
  tmp_default_client="focus-ios"
  target_client="${tmp_default_client}"

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

dry_run() {
  msg "${BLUE}Dry run mode. No commands will be executed.${NOFORMAT}"
  set -vn
}

clone_repo() {
  local repo destination
  repo="${1}"
  destination="${2}"
  msg "${YELLOW}[*] Cloning ${repo}...${NOFORMAT}"
  git clone "${repo}" "${destination}" >> export-strings.log 2>&1 || die "Failed to clone ${repo}"
  msg "\t${GREEN}[+] Cloned ${repo} into ${destination}${NOFORMAT}"
}

run_checks() {
  msg "${YELLOW}[*] Running checks...${NOFORMAT}"
  check_script_location
  check_dependencies "${dependencies[@]}"
  check_temp_artifacts "${tmp_dirs[@]}"
  msg "\t${PURPLE}[+] All checks passed. Moving on...${NOFORMAT}"
}

build_localization_tools() {
  local localization_tools_dir
  localization_tools_dir="${1}"
  msg "${YELLOW}[*] Building LocalizationTools...${NOFORMAT}"
  swift build --package-path "${localization_tools_dir}" >> export-strings.log 2>&1 || die "Failed to build LocalizationTools"
  msg "\t${GREEN}[+] LocalizationTools built successfully. Moving on...${NOFORMAT}"
}

find_replace_file_text() {
  local file_dir find_text replace_text
  file_dir=($1)
  find_text="${2}.xliff"
  replace_text="${3}.xliff"
    for file in "${file_dir[@]}"; do
    msg "${YELLOW}[*] Replacing ${find_text} with ${replace_text} in ${file}...${NOFORMAT}"
    [[ -f "$file" ]] && ed -s "${file}" <<!
    g/$find_text/s//$replace_text/g
    w
    q
!
    msg "\t${GREEN}[+] Replaced ${find_text} with ${replace_text} in ${file}${NOFORMAT}"
    done
    msg "\t${PURPLE}[+] All instances of ${find_text} replaced with ${replace_text}. Moving on...${NOFORMAT}"
}

export_strings() {
  local localization_tools_dir l10n_dir
  localization_tools_dir="${1}"
  l10n_dir="${2}"

  msg "${YELLOW}[*] Exporting strings for ${target_client}...${NOFORMAT}"
  (cd "${localization_tools_dir}" && swift run LocalizationTools --export \
    --project-path "${root_dir}/Blockzilla.xcodeproj" \
    --l10n-project-path "${l10n_dir}") >> export-strings.log 2>&1 || die "Failed to export strings for ${target_client}"
  msg "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b        ${GREEN}[+] Strings exported successfully. Moving on...${NOFORMAT}"
}

progress_spinner() {
  local pid spinner
  pid=$1
  spinner='- \ | /'
  color=("${GREEN}" "${YELLOW}" "${RED}" "${BLUE}" "${PURPLE}" "${ORANGE}" "${CYAN}" "${NOFORMAT}")
  sleep 1
  while kill -0 "$pid" 2>/dev/null; do
    for i in $spinner; do
      printf "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b${color[$RANDOM % ${#color[@]}]}%s %s %s %s %s %s %s %s${NOFORMAT}" "$i" "$i" "$i" "$i" "$i" "$i" "$i" "$i"
      sleep 0.25
    done
  done
}

main() {
  local dependencies script_dir root_dir tmp_dirs target_client
  local localization_tools_repo localization_tools focusios_l10n_repo focusios_l10n
  dependencies=(git swift)
  script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
  root_dir=$(cd "${script_dir}/.." &>/dev/null && pwd -P)
  tmp_dirs=("${root_dir}/tools/Localizations" "${root_dir}/focusios-l10n")
  localization_tools_repo="https://github.com/mozilla-mobile/LocalizationTools.git"
  localization_tools=("${localization_tools_repo}" "${tmp_dirs[0]}")
  focusios_l10n_repo="https://github.com/mozilla-l10n/focusios-l10n.git"
  focusios_l10n=("${focusios_l10n_repo}" "${tmp_dirs[1]}")

  setup_colors
  parse_params "$@"
  run_checks
  clone_repo "${localization_tools[@]}"
  clone_repo "${focusios_l10n[@]}"
  build_localization_tools "${tmp_dirs[0]}"
  find_replace_file_text "${tmp_dirs[0]}/Sources/LocalizationTools/tasks/*.swift" "firefox-ios" "${target_client}"
  export_strings "${tmp_dirs[0]}" "${tmp_dirs[1]}" "${target_client}" &
  progress_spinner $!

  msg "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b${BLUE}Read parameters:"
  msg "- Client Target: ${target_client}${NOFORMAT}"
  msg "${GREEN}Hooray!! Strings have been succesfully exported."
  msg "You can create a PR in the focusios-l10n checkout.${NOFORMAT}"
  exit
}

main "$@"