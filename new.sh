#!/usr/bin/env bash
set -euo pipefail

# digits lookup
_digits=( {0..9} {A..Z} )

to36() {
  local -i n=$1
  local out=
  local d
  for i in 0 1 2 3; do
    (( d = n % 36, n /= 36 ))
    out=${_digits[d]}$out
  done
  printf "%s\n" "$out"
}

increment36() {
  local v=${1^^}
  # parse base-36 into decimal, add 1, convert back
  local dec=$(( 36#$v + 1 ))
  to36 "$dec"
}

# Ensure TYPST_ROOT is set.
if [[ -z "${TYPST_ROOT:-}" ]]; then
  echo "Error: TYPST_ROOT is not set." >&2
  exit 1
fi

_next_file="$TYPST_ROOT/_lib/_next"
_template_file="$TYPST_ROOT/_lib/_template.typ"

# Read and validate current index
if [[ ! -f "$_next_file" ]]; then
  echo "Error: index file '$_next_file' not found." >&2
  exit 1
fi

current_id=$(<"$_next_file")
current_id=${current_id^^}  # uppercase

# must be exactly 4 chars, only 0–9 or A–Z
if [[ ! $current_id =~ ^[0-9A-Z]{4}$ ]]; then
  echo "Error: invalid index in '$_next_file': '$current_id'" >&2
  echo "       must be exactly 4 characters [0-9A-Z]." >&2
  exit 1
fi

# Increment, write back
next_id=$(increment36 "$current_id")
printf '%s' "$next_id" > "$_next_file"

# Create new note from template
new_note="$TYPST_ROOT/${next_id}.typst"
if [[ -e "$new_note" ]]; then
  echo "Error: target file '$new_note' already exists." >&2
  exit 1
fi

cp -- "$_template_file" "$new_note"

# Output the path of the created note
printf "%s\n" "$new_note"
