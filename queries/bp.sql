SELECT subject_id, hadm_id, itemid, charttime, valuenum, valueuom
FROM chartevents
WHERE itemid = 51 OR itemid = 442 OR itemid = 455 OR itemid = 6701 OR itemid = 220050 OR itemid = 220179