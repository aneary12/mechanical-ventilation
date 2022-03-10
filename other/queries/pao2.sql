select hadm_id, itemid, charttime, valueuom,
	-- put a conservative upper limit on PaO2
	case
        when itemid = 50821 and valuenum < 800 then valuenum
	else null
	end as valuenum
from labevents
where itemid = 50821
order by charttime