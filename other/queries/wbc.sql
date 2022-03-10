SELECT subject_id, hadm_id, itemid, charttime, valuenum, valueuom
FROM labevents
WHERE itemid = 51300 OR itemid = 51301