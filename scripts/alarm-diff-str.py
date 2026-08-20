#!/usr/bin/env python3

import sys
import ast
import pandas as pd

ALARM_ID_COL_IDX = 4

arquivo_1 = sys.argv[1]
string_alarms = sys.argv[2]

alarms_set = ast.literal_eval(string_alarms)

df1 = pd.read_excel(arquivo_1)

ids1 = df1.iloc[:, ALARM_ID_COL_IDX].dropna().astype(str).tolist()
ids1_set = set(ids1)

missing = []
seen = set()
for alarm_id in alarms_set:
    if alarm_id not in ids1_set and alarm_id not in seen:
        missing.append(alarm_id)
        seen.add(alarm_id)

print("\n".join(missing))
