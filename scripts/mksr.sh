#!/bin/bash

show_help() {
	cat << EOF
Usage: $0 <./path/to/body.txt>

Example:
  $0 sr-xyz.txt
EOF
exit 0
}

[[ $# -eq 0 ]] && show_help && exit 1

BODY="${1:?Usage: $0 ./paht/to/body.txt}"
TABLE="/home/bruno/Mail/SRs/table-template.html"

INDEX="/tmp/index.html"

sed '1,2d; s/$/<br>/' $BODY > $INDEX

eval "cat<<EOF
$(cat "$TABLE")
EOF
" >> $INDEX
