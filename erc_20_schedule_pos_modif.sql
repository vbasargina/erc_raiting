Truncate Table  nrpz.erc_${year}_schedule_pos_modif;		
Insert into nrpz.erc_${year}_schedule_pos_modif 
with notice as
(
select 
		p.ikz, 
		p.versionnumber,
		-- p.placingway_name, p.plan_placement_date,
		p.purchasecanceled, rn
		from 
			(select 
						ikz, 
						versionnumber, 
						planyear	as	plan_placement_date,
						case when purchasecanceled is null then 0 else 1 end purchasecanceled,
						row_number() over (partition by ikz order by versionnumber) rn
					from nrpz.dwh_tenderplan_20_acgz pos
					where pos.planyear = 20${year}  and  pos.publishdate<to_date('${date}','yyyy-mm-dd')
          and type_position <> 'specialPurchase'
										
			)p
)
select n_f.ikz, 
	   n_f.versionnumber ver_from,
	   n_s.versionnumber ver_to, 
	   case when n_f.purchasecanceled <> n_s.purchasecanceled then 1 else 0 end modiff_all
from notice n_f
join notice n_s on n_f.ikz = n_s.ikz and n_f.rn+1 = n_s.rn;
