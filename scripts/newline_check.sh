#!/usr/bin/env bash

# This should be an array of strings in bash regex format, eg
# IGNORE_PATHS=(
#  '^.*some-file-name.txt$'
#  '^some-folder/.*$'
#)
declare -a IGNORE_PATHS=()

echo_error() {
  RED="\033[31m\033[1m"
  RESET="\033[0m"
  echo -e "${RED}$*${RESET}" >&2
}

# Return 0 if file exists and has contents
is_non_empty_file() {
  [[ -s "$1" ]]
}

# Returns 0 if path matches a regex in IGNORE_PATHS
should_ignore_path() {
  for IGNORE_PATH in "${IGNORE_PATHS[@]}"; do
    [[ "$1" =~ $IGNORE_PATH ]] && return 0
  done

  return 1
}

# Return 0 if file has newline on final line
has_final_newline() {
  [[ -z "$(tail -c 1 "$1")" ]]
}

# Return 0 if file is binary (empty files are considered to be binary files)
is_binary() {
  [[ "$1" == 'i/-text' ]]
}

BAD_FILES=""

IFS=$'\n'
for FILE in $(git ls-files --eol); do
  FILETYPE="$(echo "$FILE" | xargs | cut -d' ' -f1)"
  FILEPATH="$(echo "$FILE" | xargs | cut -d' ' -f4)"

  if is_non_empty_file "$FILEPATH" && ! should_ignore_path "$FILEPATH" && ! is_binary "$FILETYPE" && ! has_final_newline "$FILEPATH"; then
    BAD_FILES="${BAD_FILES}${FILEPATH}\n"
  fi
done

if [[ -n "$BAD_FILES" ]]; then
  echo_error "Missing newline(s) at end of file(s)\n"

  printf "%b" "$BAD_FILES"

  exit 1
fi
