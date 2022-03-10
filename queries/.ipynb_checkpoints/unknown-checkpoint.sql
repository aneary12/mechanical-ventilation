with blood_gas_first_day as
(with pvt as
( -- begin query that extracts the data
  select ie.subject_id, ie.hadm_id, ie.icustay_id
  -- here we assign labels to ITEMIDs
  -- this also fuses together multiple ITEMIDs containing the same data
      , case
        when itemid = 50800 then 'SPECIMEN'
        when itemid = 50801 then 'AADO2'
        when itemid = 50802 then 'BASEEXCESS'
        when itemid = 50803 then 'BICARBONATE'
        when itemid = 50804 then 'TOTALCO2'
        when itemid = 50805 then 'CARBOXYHEMOGLOBIN'
        when itemid = 50806 then 'CHLORIDE'
        when itemid = 50808 then 'CALCIUM'
        when itemid = 50809 then 'GLUCOSE'
        when itemid = 50810 then 'HEMATOCRIT'
        when itemid = 50811 then 'HEMOGLOBIN'
        when itemid = 50812 then 'INTUBATED'
        when itemid = 50813 then 'LACTATE'
        when itemid = 50814 then 'METHEMOGLOBIN'
        when itemid = 50815 then 'O2FLOW'
        when itemid = 50816 then 'FIO2'
        when itemid = 50817 then 'SO2' -- OXYGENSATURATION
        when itemid = 50818 then 'PCO2'
        when itemid = 50819 then 'PEEP'
        when itemid = 50820 then 'PH'
        when itemid = 50821 then 'PO2'
        when itemid = 50822 then 'POTASSIUM'
        when itemid = 50823 then 'REQUIREDO2'
        when itemid = 50824 then 'SODIUM'
        when itemid = 50825 then 'TEMPERATURE'
        when itemid = 50826 then 'TIDALVOLUME'
        when itemid = 50827 then 'VENTILATIONRATE'
        when itemid = 50828 then 'VENTILATOR'
        else null
        end as label
        , charttime
        , value
        -- add in some sanity checks on the values
        , case
          when valuenum <= 0 and itemid != 50802 then null -- allow negative baseexcess
          when itemid = 50810 and valuenum > 100 then null -- hematocrit
          -- ensure FiO2 is a valid number between 21-100
          -- mistakes are rare (<100 obs out of ~100,000)
          -- there are 862 obs of valuenum == 20 - some people round down!
          -- rather than risk imputing garbage data for FiO2, we simply NULL invalid values
          when itemid = 50816 and valuenum < 20 then null
          when itemid = 50816 and valuenum > 100 then null
          when itemid = 50817 and valuenum > 100 then null -- O2 sat
          when itemid = 50815 and valuenum >  70 then null -- O2 flow
          when itemid = 50821 and valuenum > 800 then null -- PO2
           -- conservative upper limit
        else valuenum
        end as valuenum

    FROM icustays ie
    left join labevents le
      on le.subject_id = ie.subject_id and le.hadm_id = ie.hadm_id
      and le.charttime between (ie.intime - INTERVAL '6 hours') and (ie.intime + INTERVAL '1 day')
      and le.ITEMID in
      -- blood gases
      (
        50800, 50801, 50802, 50803, 50804, 50805, 50806, 50807, 50808, 50809
        , 50810, 50811, 50812, 50813, 50814, 50815, 50816, 50817, 50818, 50819
        , 50820, 50821, 50822, 50823, 50824, 50825, 50826, 50827, 50828
        , 51545
      )
)
select pvt.SUBJECT_ID, pvt.HADM_ID, pvt.ICUSTAY_ID, pvt.CHARTTIME
, max(case when label = 'SPECIMEN' then value else null end) as specimen
, max(case when label = 'AADO2' then valuenum else null end) as aado2
, max(case when label = 'BASEEXCESS' then valuenum else null end) as baseexcess
, max(case when label = 'BICARBONATE' then valuenum else null end) as bicarbonate
, max(case when label = 'TOTALCO2' then valuenum else null end) as totalco2
, max(case when label = 'CARBOXYHEMOGLOBIN' then valuenum else null end) as carboxyhemoglobin
, max(case when label = 'CHLORIDE' then valuenum else null end) as chloride
, max(case when label = 'CALCIUM' then valuenum else null end) as calcium
, max(case when label = 'GLUCOSE' then valuenum else null end) as glucose
, max(case when label = 'HEMATOCRIT' then valuenum else null end) as hematocrit
, max(case when label = 'HEMOGLOBIN' then valuenum else null end) as hemoglobin
, max(case when label = 'INTUBATED' then valuenum else null end) as intubated
, max(case when label = 'LACTATE' then valuenum else null end) as lactate
, max(case when label = 'METHEMOGLOBIN' then valuenum else null end) as methemoglobin
, max(case when label = 'O2FLOW' then valuenum else null end) as o2flow
, max(case when label = 'FIO2' then valuenum else null end) as fio2
, max(case when label = 'SO2' then valuenum else null end) as so2 -- OXYGENSATURATION
, max(case when label = 'PCO2' then valuenum else null end) as pco2
, max(case when label = 'PEEP' then valuenum else null end) as peep
, max(case when label = 'PH' then valuenum else null end) as ph
, max(case when label = 'PO2' then valuenum else null end) as po2
, max(case when label = 'POTASSIUM' then valuenum else null end) as potassium
, max(case when label = 'REQUIREDO2' then valuenum else null end) as requiredo2
, max(case when label = 'SODIUM' then valuenum else null end) as sodium
, max(case when label = 'TEMPERATURE' then valuenum else null end) as temperature
, max(case when label = 'TIDALVOLUME' then valuenum else null end) as tidalvolume
, max(case when label = 'VENTILATIONRATE' then valuenum else null end) as ventilationrate
, max(case when label = 'VENTILATOR' then valuenum else null end) as ventilator
from pvt
group by pvt.subject_id, pvt.hadm_id, pvt.icustay_id, pvt.CHARTTIME
order by pvt.subject_id, pvt.hadm_id, pvt.icustay_id, pvt.CHARTTIME
)
, stg_spo2 as
(
  select subject_id, hadm_id, icustay_id, charttime
    -- max here is just used to group SpO2 by charttime
    , max(case when valuenum <= 0 or valuenum > 100 then null else valuenum end) as SpO2
  FROM chartevents
  -- o2 sat
  where ITEMID in
  (
    646 -- SpO2
  , 220277 -- O2 saturation pulseoxymetry
  )
  group by subject_id, hadm_id, icustay_id, charttime
)
, stg_fio2 as
(
  select subject_id, hadm_id, icustay_id, charttime
    -- pre-process the FiO2s to ensure they are between 21-100%
    , max(
        case
          when itemid = 223835
            then case
              when valuenum > 0 and valuenum <= 1
                then valuenum * 100
              -- improperly input data - looks like O2 flow in litres
              when valuenum > 1 and valuenum < 21
                then null
              when valuenum >= 21 and valuenum <= 100
                then valuenum
              else null end -- unphysiological
        when itemid in (3420, 3422)
        -- all these values are well formatted
            then valuenum
        when itemid = 190 and valuenum > 0.20 and valuenum < 1
        -- well formatted but not in %
            then valuenum * 100
      else null end
    ) as fio2_chartevents
  FROM chartevents
  where ITEMID in
  (
    3420 -- FiO2
  , 190 -- FiO2 set
  , 223835 -- Inspired O2 Fraction (FiO2)
  , 3422 -- FiO2 [measured]
  )
  -- exclude rows marked as error
  AND (error IS NULL OR error = 0)
  group by subject_id, hadm_id, icustay_id, charttime
)
, stg2 as
(
select bg.*
  , ROW_NUMBER() OVER (partition by bg.icustay_id, bg.charttime order by s1.charttime DESC) as lastRowSpO2
  , s1.spo2
from blood_gas_first_day bg
left join stg_spo2 s1
  -- same patient
  on  bg.icustay_id = s1.icustay_id
  -- spo2 occurred at most 2 hours before this blood gas
  and s1.charttime >= (bg.charttime - INTERVAL '2 hours')
  and s1.charttime <= bg.charttime
where bg.po2 is not null
)
, stg3 as
(
select bg.*
  , ROW_NUMBER() OVER (partition by bg.icustay_id, bg.charttime order by s2.charttime DESC) as lastRowFiO2
  , s2.fio2_chartevents

  -- create our specimen prediction
  ,  1/(1+exp(-(-0.02544
  +    0.04598 * po2
  + coalesce(-0.15356 * spo2             , -0.15356 *   97.49420 +    0.13429)
  + coalesce( 0.00621 * fio2_chartevents ,  0.00621 *   51.49550 +   -0.24958)
  + coalesce( 0.10559 * hemoglobin       ,  0.10559 *   10.32307 +    0.05954)
  + coalesce( 0.13251 * so2              ,  0.13251 *   93.66539 +   -0.23172)
  + coalesce(-0.01511 * pco2             , -0.01511 *   42.08866 +   -0.01630)
  + coalesce( 0.01480 * fio2             ,  0.01480 *   63.97836 +   -0.31142)
  + coalesce(-0.00200 * aado2            , -0.00200 *  442.21186 +   -0.01328)
  + coalesce(-0.03220 * bicarbonate      , -0.03220 *   22.96894 +   -0.06535)
  + coalesce( 0.05384 * totalco2         ,  0.05384 *   24.72632 +   -0.01405)
  + coalesce( 0.08202 * lactate          ,  0.08202 *    3.06436 +    0.06038)
  + coalesce( 0.10956 * ph               ,  0.10956 *    7.36233 +   -0.00617)
  + coalesce( 0.00848 * o2flow           ,  0.00848 *    7.59362 +   -0.35803)
  ))) as SPECIMEN_PROB
from stg2 bg
left join stg_fio2 s2
  -- same patient
  on  bg.icustay_id = s2.icustay_id
  -- fio2 occurred at most 4 hours before this blood gas
  and s2.charttime between (bg.charttime - INTERVAL '4 hours') and bg.charttime
where bg.lastRowSpO2 = 1 -- only the row with the most recent SpO2 (if no SpO2 found lastRowSpO2 = 1)
)

select subject_id, hadm_id,
icustay_id, charttime
, specimen -- raw data indicating sample type, only present 80% of the time

-- prediction of specimen for missing data
, case
      when SPECIMEN is not null then SPECIMEN
      when SPECIMEN_PROB > 0.75 then 'ART'
    else null end as SPECIMEN_PRED
, specimen_prob
-- oxygen related parameters
, so2, spo2 -- note spo2 is FROM `physionet-data.mimiciii_clinical.chartevents`
, po2, pco2
, fio2_chartevents, fio2
, aado2
-- also calculate AADO2
, case
    when  PO2 is not null
      and pco2 is not null
      and coalesce(fio2, fio2_chartevents) is not null
     -- multiple by 100 because FiO2 is in a % but should be a fraction
      then (coalesce(fio2, fio2_chartevents)/100) * (760 - 47) - (pco2/0.8) - po2
    else null
  end as AADO2_calc

, case
    when PO2 is not null and coalesce(fio2, fio2_chartevents) is not null
     -- multiply by 100 because FiO2 is in a % but should be a fraction
      then 100*PO2/(coalesce(fio2, fio2_chartevents))
    else null
  end as PaO2FiO2

-- acid-base parameters
, ph, baseexcess
, bicarbonate, totalco2

-- blood count parameters
, hematocrit
, hemoglobin
, carboxyhemoglobin
, methemoglobin

-- chemistry
, chloride, calcium
, temperature
, potassium, sodium
, lactate
, glucose

-- ventilation stuff that's sometimes input
, intubated, tidalvolume, ventilationrate, ventilator
, peep, o2flow
, requiredo2

from stg3
where lastRowFiO2 = 1 -- only the most recent FiO2
-- restrict it to *only* arterial samples
and (specimen = 'ART' or specimen_prob > 0.75)
order by icustay_id, charttime;