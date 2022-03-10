SELECT
    i.subject_id,
    i.hadm_id,
    i.icustay_id,
    p.gender,
    p.dob,
    ROUND((CAST(a.admittime AS date) - CAST(p.dob AS date))/365.242,2) AS age,
    a.admittime,
    a.dischtime,
    i.intime,
    i.outtime,
    i.los,
    a.diagnosis,
    a.hospital_expire_flag
FROM
    icustays i
    INNER JOIN patients p ON i.subject_id = p.subject_id
    INNER JOIN admissions a ON i.hadm_id = a.hadm_id