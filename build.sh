#!/bin/sh

if [ $# = 0 ]; then
  echo 'usage: ./build.sh [-o <output>] [FILE]'
  exit 0
fi

while [ $# -gt 0 ]; do
  case "$1" in
    -o)
      shift; output=$1;;

    -h)
      echo 'usage: ./build.sh [-o <output>] [FILE]'
      echo
      echo '  -o - output file'
    ;;

    *)
      input=$1;;
  esac
  shift
done

if [ -z "$input" ]; then
  echo 'usage: ./build.sh [FILE]'
  exit 1
fi

if [ -z "$output" ]; then
  output=out.txt
fi

echo -n > "$output"

while IFS= read -r url; do
  echo -e "[\033[32mFETCH\033[m] $url"
  curl "$url" 2> /dev/null >> "$output"
done < "$input"

# Remove comments
sed -i 's/^!.*//g' "$output"

# Remove sections
sed -i 's/^\[.*//g' "$output"

# Remove blank lines
sed -i '/^$/d' "$output"

header='[Adblock Plus 3.5]
! Title: Merged filters
! Homepage: https://github.com/fenze/filters
! License: https://github.com/fenze/filters/blob/master/license
! Expires: 1 day'

echo "$header" > "$output.tmp"
cat "$output" >> "$output.tmp"
mv "$output.tmp" "$output"
