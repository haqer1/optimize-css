#!/usr/bin/env bash

Begin="[^{]+\{";
End="\}";
MultilineSuffix="multi-line"

call_sed() {
: '
  echo $1
  echo $2
  echo $3
  echo $4
  echo $5
'
  sed -r"$5" "/$Begin/,/$End/ {
    /$2/ $4
  }" $1 >> $3
}

process_replacements() {
  local in="$1"
  local out="$2"
  local emir="$3"
  local extra_option="$4"
  shift 4
  local arr=("$@")
  for i in "${arr[@]}"
  do
    echo "  /* $emir: $i */"
    call_sed "$in" "$i" "$out" "$emir" "$extra_option"
  done
}

delete_substrings() {
  local file=$1
  shift
  local arr=("$@")
  for i in "${arr[@]}"
  do
    echo "  /* s: $i */"
    sed -ri "s/$i//g" $file
  done
}

main() {
  local in="$1"
  local out="$2"
  shift 2
  local deleteArray=("$@")
  rm -f $out

  process_replacements "$in" "$out" "p" "n" "${Include[@]}"

# Removing duplicates without sorting:
  awk '!seen[$0]++' $out > $out.temp
#sort $2.temp > $2 && mv $2 $2.temp
  process_replacements "$out.temp" "$out" "d" "i" "${Exclude[@]}"
  mv $out.temp $out

# Removing duplicates with sorting would be worse:
#sort $2 > $2.temp
#sed '$!N; /^\(.*\)\n\1$/!P; D' $2.temp > $2

  delete_substrings "$out" "${deleteArray[@]}"

  cp $out $out.$MultilineSuffix
  tr -d '\n' < $out.$MultilineSuffix >  $out

  echo "Done (multi-line file: $out.$MultilineSuffix)"
}

usage() {
  cat <<EOF
Meant to be called from other scripts to optimize auto-generated CSS.
Usage:
Include=("\.applicable" "\.needed[^-:>+]+"); \\
Exclude=("\.non-applicable[^-:>+\.,]+" "\.unnecessary[^-:>+\.]+"); \\
Delete=("[^{,]*\.also-not-used,"); \\
./optimize-css.sh input_file.css output_file.css \\
<( (( \${#Include[@]} )) && printf '%s\0' "\${Include[@]}") \\
<( (( \${#Exclude[@]} )) && printf '%s\0' "\${Exclude[@]}") \\
<( (( \${#Delete[@]} )) && printf '%s\0' "\${Delete[@]}")
EOF
}

in_single_line=$1
out=$2
if [ -z $in_single_line ] || [ -z $out ]; then
  usage
  exit 1
fi

shift 2

mapfile -d '' Include <"$1"
if [ ${#Include[@]} -eq 0 ]; then
  usage
  exit 1
fi
mapfile -d '' Exclude <"$2"
mapfile -d '' Delete <"$3"

in=$in_single_line.$MultilineSuffix
sed 's/\(\}\)/\1\n/g' $in_single_line > $in

main $in $out "${Delete[@]}"
