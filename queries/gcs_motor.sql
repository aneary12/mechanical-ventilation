SELECT subject_id, hadm_id, icustay_id, itemid, charttime, valuenum, valueuom
FROM chartevents
WHERE itemid = 454 OR itemid = 223901