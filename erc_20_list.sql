Truncate Table  nrpz.erc_${year}_list;
Insert into nrpz.erc_${year}_list
Select 
	sch.org_name,
	sch.org_inn,
	sch.org_spz,
	sch.org_kgntv,
	st.grbsid,
	sch.plannumber,
	sch.versionnumber,
	sch.publishdate,
	sch.positionnumber,
	sch.ikz,
	sch.finance_total nmc_schedule,
	sch.purchasecanceled,
	sch.specialpurchase_type,
	sch.modiff_all cnt_modif_pg,	
	sch.flah_act_version,
	st.reqnum,
	st.publishdate publishdate_reqnum,
	st.sop_code  sop_code_reqnum,
	st.sop_name  sop_name_reqnum,
	st.joflag_org_name,
	st.joflag_org_spz,
	st.org_kgntv_joflag,
	st.joflag,
	st.startdate,
	st.enddate,
	st.maxprice nmc_reqnum,
	st.maxprice_all nmc_joflag,
	st.biddingdate,
	st.openingdate,
	st.scoringdate,
	st.prequalification,
	st.lotnumber,
	st.pg_pos positionnumber_reqnum,
	st.flag_comp flag_comp_reqnum,
	st.ikz ikz_reqnum,
	st.pg plannumber_reqnum,
	st.object_name object_name_reqnum,
	st.cnt_modif cnt_modif_reqnum,
	st.flag_cans flag_cans_reqnum,
	st.purchasenumber_rn,
	st.flag_smp -- флаг смп от 01.04.2025
From nrpz.erc_${year}_schedule_pos sch
Inner Join nrpz.erc_${year}_start_notice st On (sch.positionnumber = st.pg_pos)
Union 
Select 
	sch.org_name,
	sch.org_inn,
	sch.org_spz,
	sch.org_kgntv,
	sch.grbsid,
	sch.plannumber,
	sch.versionnumber,
	sch.publishdate,
	sch.positionnumber,
	sch.ikz,
	sch.finance_total nmc_schedule,
	sch.purchasecanceled,
	sch.specialpurchase_type,
	sch.modiff_all cnt_modif_pg,			
	sch.flah_act_version,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	0
From nrpz.erc_${year}_schedule_pos sch
Left Join (Select 
				Distinct pg_pos 
		   From nrpz.erc_${year}_start_notice
		   )st On (st.pg_pos = sch.positionnumber)
Where st.pg_pos Is Null 
And sch.flah_act_version = 1;

delete from nrpz.erc_${year}_list
where grbsid is null;

-- совместные закупки, у которых организатор не заказчик из СПБ (0387200009125004298,0387200009125004301,0387200009125004307)
delete from nrpz.erc_${year}_list
WHERE joflag = 1 AND org_kgntv_joflag IS NULL;