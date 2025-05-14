truncate table nrpz.erc_${year}_data_demand;
insert into nrpz.erc_${year}_data_demand
select  srl.org_kgntv,
		eo.orgtitle grbstitle,
        dok.full_name,
        dok.inn,
		srl.REQNUM,
		srl.publishdate_reqnum,
        -- числитель 8, 7, 6 показателя, знаменатель 6,7,8 показателя
        max(sd_denominator.max_PUBL) max_PUBL_zn,
		max(sd_denominator.min_PUBL) min_PUBL_zn,
		max(sd_denominator.cnt_all) cnt_all_zn,
		max(sd_denominator.cnt_adm) cnt_adm_zn,
        max(sd_denominator.title) title_protocol_zn,
		max(sd_denominator.flag_protocol) flag_protocol_zn,
		srl.flag_smp,
		srl.sop_name_reqnum,
		ais.lotuuid, ais.requestid
    from (select REQNUM, max(publishdate_reqnum) publishdate_reqnum, sop_name_reqnum,joflag, sop_code_reqnum, flag_smp,
						case 
                             when joflag = 1 and org_kgntv_joflag in (1412, 592) then grbsid
                             when joflag = 1 and org_kgntv_joflag not in  (1412, 592) then org_kgntv_joflag 
                        else org_kgntv end org_kgntv   
					from nrpz.erc_${year}_list_contract  
					where flag_comp_reqnum = 1 AND  sop_code_reqnum in ('OKB20','OKP20','EAB20', 'EAP20', 'EAO20', 'EEA20','ZKP20','EOK20','OKI20', 'OKA20','EZK20') --31.10.24 добавлен EZK20, т.к. не попападала заяка по извещению 0372200101124000043
					AND reqnum NOT IN (SELECT reqnum 
									   FROM nrpz.erc_${year}_list_contract 
									   WHERE joflag = 1 AND org_kgntv_joflag in (1412, 592) 
									   group BY reqnum 
									   HAVING count(DISTINCT grbsid) > 1) -- 01.04.25 не берем совместные закупки, у которых орг КГЗ или Дирекция, а заказчики относятся к разным ГРБС
					group by REQNUM, sop_name_reqnum, joflag, sop_code_reqnum, flag_smp,
					case 
                             when joflag = 1 and org_kgntv_joflag in (1412, 592) then grbsid
                             when joflag = 1 and org_kgntv_joflag not in  (1412, 592) then org_kgntv_joflag 
                        else org_kgntv end 
				)srl
     join nrpz.erc_${year}_demand sd on srl.REQNUM = sd.purchasenumber And sd.flag_protocol in ('1','2','3') and sd.prolonflag is null
     -- знаменатель (учитываюся минимальные) / числитель письмо от 06.03.2022
     left join (select * from nrpz.erc_${year}_demand where (purchasenumber, flag_protocol) in (select purchasenumber,min(flag_protocol)flag_protocol1 from nrpz.erc_${year}_demand group by purchasenumber)) sd_denominator on srl.REQNUM = sd_denominator.purchasenumber And sd_denominator.flag_protocol in ('1','2','3') and sd_denominator.prolonflag is null
     -- числитель (учитываюся итоговые)
     join nrpz.erc_dwh_organization_kgntv dok on dok.id = srl.org_kgntv
	 join nrpz.erc_dwh_organization_kgntv dokgrbs on dokgrbs.id = dok.parentid
	 join nrpz.ERC_ORGANIZATION eo	on eo.spz = dokgrbs.spz
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
	)ais on ais.reqnum = srl.REQNUM
    group by
    srl.org_kgntv,
    eo.orgtitle,
    dok.full_name,
    dok.inn,
    srl.REQNUM,
    srl.publishdate_reqnum,
    srl.sop_name_reqnum,
    ais.lotuuid, ais.requestid, flag_smp;
