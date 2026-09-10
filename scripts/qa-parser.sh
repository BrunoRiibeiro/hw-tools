#!/bin/bash

normalize_year() {
	local y=$1
	((y < 100)) && echo $((y + 2000)) || echo $y
}

INPUT_PATH=$1
PERCENT=$2
SMONTH=$3
SYEAR=$(normalize_year $4)
if [[ -n $5 ]] && [[ -n $6 ]]; then
	EMONTH=$5
	EYEAR=$(normalize_year $6)
	TODATE=" to $(printf '%02d' $EMONTH)/$EYEAR"
else
	EMONTH=$SMONTH
	EYEAR=$SYEAR
fi
COL_IDX=6

((PERCENT <= 0)) && echo "PERCENTAGE must be > 0." && exit 1
((PERCENT > 100)) && echo "PERCENTAGE must be <= 100." && exit 1

OUTPUT_PATH="${INPUT_PATH%%.xlsx}_filtered_${PERCENT}p_from_$(printf '%02d' ${SMONTH})_${SYEAR}.xlsx"
echo $OUTPUT_PATH

python3 <<PY
import sys
import pandas as pd
df = pd.read_excel('$INPUT_PATH', sheet_name=0)
creation_series = df.iloc[:, $COL_IDX]
dt = pd.to_datetime(creation_series, errors="coerce")
start = pd.Timestamp(year=$SYEAR, month=$SMONTH, day=1)
end = pd.Timestamp(year=$EYEAR, month=$EMONTH, day=1) + pd.offsets.MonthEnd(0)
filtered = df[(dt >= start) & (dt <= end)]
print(f"0K! Filtered rows from $(printf '%02d' $SMONTH)/$SYEAR$TODATE: {len(filtered)}")
frac = $PERCENT / 100.0
if frac >= 1:
    sampled = filtered
else:
    sampled = filtered.sample(frac=frac)
print(f"Sample ($PERCENT%): {len(sampled)}")
sampled.to_excel('$OUTPUT_PATH', index=False)
print("Created file: $OUTPUT_PATH")
PY
