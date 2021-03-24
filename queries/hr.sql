SELECT subject_id, hadm_id, itemid, charttime, valuenum, valueuom
FROM chartevents
WHERE itemid = 211 OR itemid = 220045