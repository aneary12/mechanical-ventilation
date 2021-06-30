select subject_id, hadm_id, icustay_id, itemid, starttime, amount, amountuom
from inputevents_mv
where itemid = 221744