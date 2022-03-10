SELECT subject_id, hadm_id, itemid, charttime, valuenum, valueuom
FROM labevents
WHERE itemid = 50822 OR itemid = 50971