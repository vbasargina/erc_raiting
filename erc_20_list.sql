Truncate Table  nrpz.erc_${year}_list;
Insert into nrpz.erc_${year}_list
SELECT
    sch.org_name,
    sch.org_inn,
    sch.org_spz,
    sch.org_kgntv,
    coalesce(st.grbsid,sch.grbsid) as grbsid,
    sch.plannumber,
    sch.versionnumber,
    sch.publishdate,
    sch.positionnumber,
    sch.ikz,
    sch.finance_total  AS nmc_schedule,
    sch.purchasecanceled,
    sch.specialpurchase_type,
    sch.modiff_all AS cnt_modif_pg,
    sch.flah_act_version,
    st.reqnum,
    st.publishdate AS publishdate_reqnum,
    st.sop_code AS sop_code_reqnum,
    st.sop_name AS sop_name_reqnum,
    st.joflag_org_name,
    st.joflag_org_spz,
    st.org_kgntv_joflag,
    st.joflag,
    st.startdate,
    st.enddate,
    st.maxprice AS nmc_reqnum,
    st.maxprice_all AS nmc_joflag,
    st.biddingdate,
    st.openingdate,
    st.scoringdate,
    st.prequalification,
    st.lotnumber,
    st.pg_pos AS positionnumber_reqnum,
    st.flag_comp AS flag_comp_reqnum,
    st.ikz AS ikz_reqnum,
    st.pg AS plannumber_reqnum,
    st.object_name AS object_name_reqnum,
    st.cnt_modif AS cnt_modif_reqnum,
    st.flag_cans AS flag_cans_reqnum,
    st.purchasenumber_rn,
    COALESCE(st.flag_smp, 0) AS flag_smp
FROM nrpz.erc_${year}_schedule_pos sch
LEFT JOIN nrpz.erc_${year}_start_notice st
       ON st.pg_pos = sch.positionnumber
WHERE
      st.pg_pos IS NOT NULL
   OR sch.flah_act_version = 1;

delete from nrpz.erc_${year}_list
where grbsid is null;

-- совместные закупки, у которых организатор не заказчик из СПБ (0387200009125004298,0387200009125004301,0387200009125004307)
delete from nrpz.erc_${year}_list
WHERE joflag = 1 AND org_kgntv_joflag IS NULL;