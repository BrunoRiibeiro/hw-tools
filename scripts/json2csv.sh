#!/usr/bin/env bash

JSON_FILE=$1
CSV_FILE="${JSON_FILE%%.json}.csv"
SC_CSV_FILE="${JSON_FILE%%.json}-semicoolon.csv"

if ! command -v jq &> /dev/null; then
	echo "Erro: jq not installed." >&2
	exit 1
fi

# | sed 's/,/;/g'
headers=$(jq -r '(.datas // .vdcs)[0] | keys_unsorted | @csv' "$JSON_FILE")
rows=$(jq -r '(.datas // .vdcs)[] | [.[]] | @csv' "$JSON_FILE")

{
  printf '\xEF\xBB\xBF'
  printf "%s\n" "$headers"
  printf "%s\n" "$rows"
} > "$CSV_FILE"

sed 's/,/;/g' "$CSV_FILE" > "$SC_CSV_FILE"

echo "Conversão concluída: $CSV_FILE"
