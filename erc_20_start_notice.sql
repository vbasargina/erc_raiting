Truncate Table nrpz.erc_${year}_start_notice; 
Insert into nrpz.erc_${year}_start_notice
Select 
	s.org_kgntv,
	s.org_kgntv_schedule, 
	s.org_kgntv_notice,
	s.org_kgntv_joflag,
	s.reqnum,
	gr.date_min as publishdate,
	s.sop_code,
	s.sop_name,
	s.org_spz,
	s.org_name,
	s.grbsid,
	s.joflag_org_name,
	s.joflag_org_spz,
	s.joflag,
	s.startdate,
	s.enddate,
	s.maxprice,
	s.maxprice_all,
	s.currency,
	s.biddingdate,--дата и время проведения аукциона в электронной форме
	s.openingdate,--дата и время вскрытия конвертов, открытии доступа к электронным документам заявок участников
	s.scoringdate,--дата рассмотрения первых частей заявок учасников или дата рассмотрения и оценки заявок на участие в конкурсе
	s.prequalification,--дата и время предквалификационного отбора
	s.lotnumber,
	s.pg_pos,
	s.flag_comp,
	s.ikz,
	s.pg,
	s.object_name,
	s.flag_cans,
	s.flag_smp, -- флаг смп от 01.04.2025
	Greatest(gr.cnt - 1, 0) cnt_modif,
	gr.date_max,
	Row_number() over (Partition By s.ikz,s.org_kgntv Order By s.flag_cans, Case When c.purchasenumber Is Not Null Then 1 Else 0 End Desc,Case When p.purchasenumber Is Not Null Then 1 Else 0 End Desc,s.publishdate Desc)  purchasenumber_rn
From 	
	(Select 
		sch.org_kgntv org_kgntv_SCHEDULE,
		org.id org_kgntv_notice,
		org_joflag.id org_kgntv_joflag,
		coalesce(org.id,sch.org_kgntv ) org_kgntv,
		org.parentid grbsid,
		st.purchasenumber reqnum,
		st.docpublishdate publishdate,
		Case 
			When joflagjo.purchasenumber Is Not Null Then 1 Else 0 End joflag,
		Case 
			When st.responsiblerole In ('OAU','OCC','OCS','OOA','OAI','ORA','OCU','RA') Then st.regnum Else Null End joflag_org_spz,
		Case 
			When st.responsiblerole In ('OAU','OCC','OCS','OOA','OAI','ORA','OCU','RA') Then st.fullname Else Null End joflag_org_name,
		Case 
			When st.responsiblerole In ('OAU','OCC','OCS','OOA','OAI','ORA','OCU','RA') Then st.customer_regnum Else st.regnum End org_spz,
		Case 
			When st.responsiblerole In ('OAU','OCC','OCS','OOA','OAI','ORA','OCU','RA') Then st.customer_fullname Else st.fullname End org_name,
		st.codeplacingway sop_code,
		st.nameplacingway sop_name,	
		Case 
			When st.nameplacingway Not In ('Закупка у единственного поставщика (подрядчика, исполнителя)','Закупка товара у единственного поставщика на сумму, предусмотренную частью 12 статьи 93 Закона № 44-ФЗ','Закупка, осуществляемая в соответствии с частью 12 статьи 93 Закона № 44-ФЗ') Then 1 Else 0 End flag_comp,
--добалвено "Закупка товара у единственного поставщика на сумму, предусмотренную частью 12 статьи 93 Закона № 44-ФЗ" по письму Тереховой 26.10.2021
		st.startdate,--дата и время начала подачи заявок
		st.enddate,--дата и время окончания подачи заявок
		st.maxprice,
		st.maxprice_all,
		st.currency,
		st.biddingdate,--дата и время проведения аукциона в электронной форме
		st.openingdate,--дата и время вскрытия конвертов, открытии доступа к электронным документам заявок участников
		st.scoringdate,--дата рассмотрения первых частей заявок участников или дата рассмотрения и оценки заявок на участие в конкурсе
		st.prequalification,--Дата и время предквалификационного отбора
		coalesce(st.lotnumber,1) lotnumber,
		st.positionnumber pg_pos,
		st.purchasecode ikz,
		st.tenderplan pg,
		st.purchaseobjectinfo object_name,
	    st.flag_smp, -- флаг смп от 01.04.2025
		Case 
			When canc.purchasenumber Is Not Null Then 1 Else 0 End flag_cans,
		row_number() over (partition by st.purchasenumber, 
						coalesce(st.lotnumber,1), 
						Case When st.responsiblerole In ('OAU','OCC','RA','OCS','OOA','OAI','ORA','OCU') Then st.customer_regNum Else st.regnum End -- берётся не СПЗ организатора а СПЗ участника
					order by st.DOCPUBLISHDATE desc) rn
	From nrpz.dwh_start_notice_cons_acgz st
	Left Join nrpz.erc_dwh_organization_kgntv org On Case When st.responsiblerole In ('OAU','OCC','OCS','OOA','OAI','ORA','OCU','RA') Then st.customer_regNum Else st.regnum End = org.spz --07.11.2019 добавлено 'RA'
	Left Join nrpz.erc_dwh_organization_kgntv org_joflag On Case When st.responsiblerole In ('OAU','OCC','OCS','OOA','OAI','ORA','OCU','RA') Then st.regnum Else Null End = org_joflag.spz --07.11.2019 добавлено 'RA'
	Inner Join (Select 
					Distinct positionnumber, org_kgntv
				From nrpz.erc_${year}_schedule_pos
				) sch On sch.positionnumber = st.positionnumber 
	Left Join (Select
					purchasenumber,
					Count(Distinct customer_regnum)
			   From nrpz.dwh_start_notice_cons_acgz
			   Where docpublishdate < To_date('${date}','yyyy-mm-dd')
			   Group By purchasenumber
			   Having Count(Distinct customer_regnum)>1
				)joflagjo On joflagjo.purchasenumber=st.purchasenumber
	Left Join 
			(select
                purchasenumber,
                Max(case 
                        when name in ('epNotificationCancel','fcsNotificationCancel') then docpublishdate 
                        else null 
                    end) docpublishdate,
                Max(case 
                        when name in ('fcsNotificationCancelFailure','epNotificationCancelFailure') then docpublishdate 
                        else null 
                    end) docpublishdate_fail
             From nrpz.dwh_start_notice_canc_acgz     
             Where docpublishdate < to_date('${date}','yyyy-mm-dd')
             Group by purchasenumber 
			)canc	on canc.purchasenumber = st.purchasenumber and canc.docpublishdate>coalesce(canc.docpublishdate_fail,'01.01.2020')  
	Where  st.docpublishdate <to_date('${date}','yyyy-mm-dd')
	) s
Inner Join(Select  
				purchasenumber reqnum,
				Count ( Distinct date_trunc('day', docpublishdate) ) cnt,
				Max(docpublishdate) date_max,
				Min(docpublishdate) date_min
			From nrpz.dwh_start_notice_cons_acgz
			Where  docpublishdate <to_date('${date}','yyyy-mm-dd')
			Group By purchasenumber
			)gr	On gr.reqnum = s.reqnum
Left Join (Select 
				Distinct purchasenumber
		   From nrpz.dwh_protocol_nrpz_acgz) p On p.purchasenumber = s.reqnum
Left Join (Select 
				Distinct notificationnumber purchasenumber 
		   From nrpz.dwh_contract_notice_nrpz_acgz) c On c.purchasenumber = s.reqnum
Where s.rn = 1;

-- правка П3.4 1 кв 2025
UPDATE nrpz.erc_${year}_start_notice
SET flag_smp = 0
WHERE reqnum = '0372200283825000008';
