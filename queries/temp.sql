SELECT subject_id, hadm_id, itemid, charttime, valuenum, valueuom
FROM chartevents
WHERE itemid = 676 OR itemid = 678 OR itemid = 223761 OR itemid = 223762