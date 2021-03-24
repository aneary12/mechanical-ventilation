with lab_spo2 as
(
	select hadm_id, itemid, charttime, valueuom,
		-- ensure SpO2 is in the right range
		case
        	when itemid = 50817 and valuenum >= 0 and valuenum <= 100 then valuenum
		else null
		end as valuenum
	from labevents
	where itemid = 50817
)

, chart_spo2 as
(
	select hadm_id, itemid, charttime, valueuom,
		-- ensure SpO2 is in the right range
		case
			when itemid = 646 and valuenum >= 0 and valuenum <= 100 then valuenum
			when itemid = 220277 and valuenum >= 0 and valuenum <= 100 then valuenum
		else null
		end as valuenum
	from chartevents
	where itemid in
	(
		646, -- SpO2
		220277 -- O2 saturation pulseoxymetry
	)
	and (error is NULL or error = 0)
)

select * from lab_spo2
union
select * from chart_spo2
order by charttime