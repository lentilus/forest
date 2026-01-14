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


base="${1:-}"

# validate base
if [[ -n "$base" && "$base" = /* ]]; then
  echo "Error: first argument must be a path relative to TYPST_ROOT, not absolute." >&2
  exit 1
fi

# Construct base directory: if base empty => use TYPST_ROOT; otherwise TYPST_ROOT/<base>
if [[ -n "$base" ]]; then
  base_dir="$TYPST_ROOT/$base"
else
  base_dir="$TYPST_ROOT"
fi

_lib_dir="$base_dir/_lib"
_next_file="$_lib_dir/_next"
_template_file="$_lib_dir/_template"
_extension_file="$_lib_dir/_extension"

# Validate extension file existence
if [[ ! -f "$_extension_file" ]]; then
  echo "Error: extension file '$_extension_file' not found." >&2
  exit 1
fi

# Read and normalize extension (trim whitespace/newlines)
ext_raw=$(tr -d ' \t\r\n' < "$_extension_file" || true)
if [[ -z "$ext_raw" ]]; then
  echo "Error: extension in '$_extension_file' is empty." >&2
  exit 1
fi

# Ensure extension starts with a dot
if [[ "${ext_raw:0:1}" != "." ]]; then
  ext=".$ext_raw"
else
  ext="$ext_raw"
fi

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

# Ensure target directory exists
if [[ ! -d "$base_dir" ]]; then
  echo "Error: target directory '$base_dir' does not exist." >&2
  exit 1
fi

# Ensure template exists
if [[ ! -f "$_template_file" ]]; then
  echo "Error: template file '$_template_file' not found." >&2
  exit 1
fi

# Create new note using the per-directory extension
new_note="$base_dir/${next_id}${ext}"
if [[ -e "$new_note" ]]; then
  echo "Error: target file '$new_note' already exists." >&2
  exit 1
fi

cp -- "$_template_file" "$new_note"

# Output the path of the created note
printf "%s\n" "$new_note"
