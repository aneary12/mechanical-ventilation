SELECT subject_id, hadm_id, itemid, charttime, valuenum, valueuom
FROM chartevents
WHERE itemid = 618 OR itemid = 220210