input_file=$1
output_file=$2

if [ -z $input_file ] || [ -z $output_file ]; then
  echo "Optimizes auto-generated CSS for a project using only PrimeNG pTooltip"
  echo "Usage: optimize-css.4.primeng.pTooltip-only.sh input_file.css output_file.css"
  exit 1
fi

Include=("\.marker" "\.p-component[^-:>+]+" "\.p-tooltip[^-:>+\.]+" "\.p-tooltip-top[^-:>+\.]+" "\.p-tooltip-arrow[^-:>+\.]+" "\.p-tooltip-text[^-:>+\.]+"); \
Exclude=("\.p-tooltip-bottom[^-:>+\.,]+" "\.p-tooltip-left[^-:>+\.]+" "\.p-tooltip-right[^-:>+\.]+"); \
Delete=("[^{,]*\.p-tooltip-bottom,"); \
./optimize-css.sh $input_file $output_file \
<( (( ${#Include[@]} )) && printf '%s\0' "${Include[@]}") \
<( (( ${#Exclude[@]} )) && printf '%s\0' "${Exclude[@]}") \
<( (( ${#Delete[@]} )) && printf '%s\0' "${Delete[@]}")
