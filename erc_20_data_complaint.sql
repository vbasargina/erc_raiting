-- Детализация жалобы
truncate table nrpz.erc_${year}_data_complaint;
insert into nrpz.erc_${year}_data_complaint
select eo.orgtitle fgrbsname,
  sc.org_kgntv, 
	sc.org_name,
	sc.joflag, 
	sc.joflag_org_name, 
	c.com_number, 
	c.check_number, 
	c.reqnum, 
	c.chec_date, 
	c.chec_pres_date::date chec_pres_date, 
	case when c.result = 'COMPLAINT_VIOLATIONS' then 'Обоснована' when c.result = 'COMPLAINT_PARTLY_VALID' then 'Обоснована частично' else null end result, 
	c.prescriptionnumber, 
  c.complaint_publishdate,
	ais.lotuuid, 
  ais.requestid,
	c.sub_fullname,
	c.sub_inn
from 
	(select distinct REQNUM, joflag,
					case when joflag = 1 then org_kgntv_joflag else grbsid end org_kgntv,
					case when joflag = 1 then joflag_org_name else org_name end org_name,
                    joflag_org_name
		from nrpz.erc_${year}_list_contract  
		where flag_comp_reqnum = 1 and (case when org_kgntv_joflag in (1412, 592) and joflag = 1 then 1 else 0 end)=0
	) sc 
left join nrpz.ERC_${year}_CHECKRESULT_BASE c on c.REQNUM = sc.REQNUM 	
join nrpz.erc_dwh_organization_kgntv dok on dok.id = sc.org_kgntv
inner join nrpz.erc_dwh_organization_kgntv dokgrbs   on dokgrbs.id = dok.parentid
inner join nrpz.ERC_ORGANIZATION eo   on eo.spz = dokgrbs.spz	 
left join 
	(select reqnum, 
		string_agg(lotuuid::varchar, '; ' order by reqnum) lotuuid, 
		string_agg(requestid::varchar, '; ' order by reqnum) requestid
	from 
		(select reqnum,lotuuid,requestid, row_number () over (partition by reqnum order by 1) rn
			from (select distinct reqnum,lotuuid,requestid  from nrpz.erc_dwh_procedures_kgntv_${srez_number}_6 where reqnum is not null)  p
		)
		where rn < 100		
	group by reqnum
	)ais on ais.reqnum = sc.reqnum
  where com_number is not null;
