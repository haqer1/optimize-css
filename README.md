# optimize-css
Just a thought for optimization of auto-generated CSS files.

## Motivation
E.g., an auto-generated CSS file of 137498 bytes could be optimized to 1000 bytes. This was the case
for **./optimize-css.4.primeng.pTooltip-only.sh**, written while looking into the aspect of avoiding
the CPU & bandwidth overhead associated with serving unnecessary CSS content during a project.

## Code
Currently there are 2 bash scripts under **sh/**.

**optimize-css.sh** is meant to be re-usable by other customized scripts.

## Usage
This requires providing the regex to include, exclude (or delete sub-strings based on), similar to
the **./optimize-css.4.primeng.pTooltip-only.sh** example. I.e., customizing the first 3 lines in
the snippet below (& not forgetting to input the paths to the input & output CSS files on line 4
:smile:).

```bash
Include=("\.applicable" "\.needed[^-:>+]+"); \
Exclude=("\.non-applicable[^-:>+\.,]+" "\.unnecessary[^-:>+\.]+"); \
Delete=("[^{,]*\.also-not-used,"); \
optimize-css.sh input_file.css output_file.css \
<( (( ${#Include[@]} )) && printf '%s\0' "${Include[@]}") \
<( (( ${#Exclude[@]} )) && printf '%s\0' "${Exclude[@]}") \
<( (( ${#Delete[@]} )) && printf '%s\0' "${Delete[@]}")
```
