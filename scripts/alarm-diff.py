#!/usr/bin/env python3

import sys
import pandas as pd

COL1_IDX = 54
COL2_IDX = 4

arquivo_1 = sys.argv[1]
arquivo_2 = sys.argv[2]

df1 = pd.read_excel(arquivo_1)
df2 = pd.read_excel(arquivo_2)

ids1 = df1.iloc[:, COL1_IDX].dropna().astype(str).tolist()
ids2_set = set(df2.iloc[:, COL2_IDX].dropna().astype(str).tolist())

seen = set()
missing = []
for alarm_id in ids1:
	if alarm_id not in ids2_set and alarm_id not in seen:
		missing.append(alarm_id)
		seen.add(alarm_id)

print("\n".join(missing))
