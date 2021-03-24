with lab_fio2 as
(
	select hadm_id, itemid, charttime, valueuom,
		-- ensure FiO2 is a valid number between 21-100
		-- mistakes are rare (<100 obs out of ~100,000)
		-- there are 862 obs of valuenum == 20 - some people round down!
		-- rather than risk imputing garbage data for FiO2, we simply NULL invalid values
		case
          when itemid = 50816 and valuenum >= 20 and valuenum <= 100 then valuenum
		else null
		end as valuenum
	from labevents
	where itemid = 50816
)

, chart_fio2 as
(
	select hadm_id, itemid, charttime, valueuom,
		case
			-- well formatted but not in %
			when itemid = 190 and valuenum >= 0.2 and valuenum <= 1.0 then valuenum * 100
			-- all these values are well formatted		
			when itemid in (3420, 3422) then valuenum
			-- these values can be formatted in different ways
			when itemid = 223835 then case
				when valuenum >= 0.2 and valuenum <= 1.0 then valuenum * 100
				when valuenum >= 20 and valuenum <= 100 then valuenum
			else null
			end
		else null
		end as valuenum
	from chartevents
	where itemid in
	(
		190, -- FiO2 set
		3420, -- FiO2
		3422, -- FiO2 (measured)
  		223835 -- Inspired O2 Fraction (FiO2)
	)
	and (error is NULL or error = 0)
)

select * from lab_fio2
union
select * from chart_fio2
order by charttime