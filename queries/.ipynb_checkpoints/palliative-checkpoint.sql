with codes as
(
	select ce.icustay_id, ce.charttime, ie.outtime,
		case
			when ce.value = 'Comfort Measures' then 1
      		when ce.value in ('CPR Not Indicate','CPR Not Indicated') then 1
      		when ce.value in ('Do Not Intubate','Do Not Intubate') then 1
      		when ce.value in ('Do Not Resuscita','Do Not Resuscitate') then 1
		else 0 end as codestatus	
	from chartevents ce, icustays ie
	where 
		ce.icustay_id = ie.icustay_id and 
		ce.itemid in (128, 223758) and
		ce.value in (
			'Comfort Measures',
			'CPR Not Indicate','CPR Not Indicated',
			'Do Not Intubate','Do Not Intubate',
			'Do Not Resuscita','Do Not Resuscitate'
		)
)
select icustay_id, outtime, 
	min(charttime) as palliativetime,
	case
		when outtime >= min(charttime) then 1
	else 0 end as palliativeatdisch,
	max(codestatus) as palliative
from codes
group by icustay_id, outtime