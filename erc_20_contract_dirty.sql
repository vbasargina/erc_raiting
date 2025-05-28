Truncate Table nrpz.erc_${year}_contract_dirty;
Insert into nrpz.erc_${year}_contract_dirty
WITH con AS(
SELECT * FROM 
(SELECT DISTINCT ON (c.regnum) 
0 NOTICE,
c.regnum rnk,
c.number_ rnk_number,
c.purchasecode ikz,
date_trunc('day',c.signdate) signdate,
c.publishdate,
c.versionnumber,
c.notificationnumber,
coalesce(c.lotnumber,'1')lotnumber,
c.placing sop_code,
	Case 
		When c.placing In ('13013') Then 'запрос котировок в электронной форме'
		When c.placing In ('12011') Then 'аукцион в электронной форме'
		When c.placing In ('14013') Then 'запрос предложений в электронной форме'
		When c.placing In ('20000') or c.placing Is Null And c.singlecustomer Is Not Null Then 'закупка у единственного поставщика (подрядчика, исполнителя)'
		When c.placing In ('11013') Then 'открытый конкурс в электронной форме'
		When c.placing In ('11031','11033') Then 'двухэтапный конкурс в электронной форме'
		When c.placing In ('13011') Then 'запрос котировок'
		When c.placing In ('11023') Then 'конкурс с ограниченным участием в электронной форме'
		When c.placing In ('30000') Then 'способ определения поставщика (подрядчика, исполнителя),  установленный правительством российской федерации в соответствии со статьей 111 федерального закона'
		When c.placing In ('14011') Then 'запрос предложений'
		When c.placing In ('11011') Then 'открытый конкурс'
		When c.placing In ('11042') Then 'закрытый конкурс'
		When c.placing In ('11021') Then 'конкурс с ограниченным участием'
		When c.placing In ('12022') Then 'закрытый аукцион'
		When c.placing In ('40000') Then 'закупка товара у единственного поставщика на сумму, предусмотренную частью 12 статьи 93 закона № 44-фз'
		Else Null End sop_name,
c.singlecustomer,
c.singlecustomer_name,
c.schedule_year,
c.protocoldate,
c.price,
	Case 
		When c.currentcontractstage = 'e' Then 'исполнение'
		When c.currentcontractstage = 'et' Then 'исполнение прекращено'
		When c.currentcontractstage = 'ec' Then 'исполнение завершено'
		When c.currentcontractstage = 'in' Then 'aннулировано'
		Else Null End stage,
c.supplier_fullname,
c.supplier_inn,
c.supplier_kpp,
c.product_name object_name,
c.customer_fullname org_name,
c.customer_inn org_inn,
c.customer_regnum org_spz,	
c.id,
c.positionnumber,
c.pricetype,
date_trunc('day', c.executions_date) executions_date,
c.customer_regnum,
c.customer_inn
FROM nrpz.dwh_contract_notice_nrpz_acgz c
WHERE c.name Like '%contract' 
And c.signdate >= to_date('${start_date}','yyyy-mm-dd') 
And c.signdate <= to_date('${date}','yyyy-mm-dd')
And c.publishdate <= to_date('${date2}','yyyy-mm-dd')
ORDER BY rnk, versionnumber, publishdate)
UNION ALL
SELECT * FROM (
SELECT DISTINCT ON (c.regnum) 
1 NOTICE,
c.regnum rnk,
c.number_ rnk_number,
c.purchasecode ikz,
date_trunc('day',c.signdate) signdate,
c.publishdate,
c.versionnumber,
c.notificationnumber,
coalesce(c.lotnumber,'1')lotnumber,
c.placing sop_code,
	Case 
		When c.placing In ('13013') Then 'запрос котировок в электронной форме'
		When c.placing In ('12011') Then 'аукцион в электронной форме'
		When c.placing In ('14013') Then 'запрос предложений в электронной форме'
		When c.placing In ('20000') or c.placing Is Null And c.singlecustomer Is Not Null Then 'закупка у единственного поставщика (подрядчика, исполнителя)'
		When c.placing In ('11013') Then 'открытый конкурс в электронной форме'
		When c.placing In ('11031','11033') Then 'двухэтапный конкурс в электронной форме'
		When c.placing In ('13011') Then 'запрос котировок'
		When c.placing In ('11023') Then 'конкурс с ограниченным участием в электронной форме'
		When c.placing In ('30000') Then 'способ определения поставщика (подрядчика, исполнителя),  установленный правительством российской федерации в соответствии со статьей 111 федерального закона'
		When c.placing In ('14011') Then 'запрос предложений'
		When c.placing In ('11011') Then 'открытый конкурс'
		When c.placing In ('11042') Then 'закрытый конкурс'
		When c.placing In ('11021') Then 'конкурс с ограниченным участием'
		When c.placing In ('12022') Then 'закрытый аукцион'
		When c.placing In ('40000') Then 'закупка товара у единственного поставщика на сумму, предусмотренную частью 12 статьи 93 закона № 44-фз'
		Else Null End sop_name,
c.singlecustomer,
c.singlecustomer_name,
c.schedule_year,
c.protocoldate,
c.price,
	Case 
		When c.currentcontractstage = 'e' Then 'исполнение'
		When c.currentcontractstage = 'et' Then 'исполнение прекращено'
		When c.currentcontractstage = 'ec' Then 'исполнение завершено'
		When c.currentcontractstage = 'in' Then 'aннулировано'
		Else Null End stage,
c.supplier_fullname,
c.supplier_inn,
c.supplier_kpp,
c.product_name object_name,
c.customer_fullname org_name,
c.customer_inn org_inn,
c.customer_regnum org_spz,	
c.id,
c.positionnumber,
c.pricetype,
date_trunc('day', c.executions_date) executions_date,
c.customer_regnum,
c.customer_inn
FROM nrpz.dwh_contract_notice_nrpz_acgz c
WHERE c.name Like '%contract' 
And c.signdate >= to_date('${start_date}','yyyy-mm-dd') 
And c.signdate <= to_date('${date}','yyyy-mm-dd')
And c.publishdate <= to_date('${date2}','yyyy-mm-dd')
ORDER BY rnk, versionnumber desc, publishdate DESC
))
,
notice As
( Select 
	c.NOTICE,
	c.rnk,
	c.rnk_number,
	c.ikz,
	c.signdate, 
	c.publishdate,
	c.versionnumber,
	c.notificationnumber,
	c.lotnumber,
	c.sop_code,
	c.sop_name,
	c.singlecustomer,
	coalesce(rs.name,c.singlecustomer_name)  singlecustomer_name,
	c.schedule_year,
	c.protocoldate,
	c.price,
	c.stage,		
	c.supplier_fullname,
	c.supplier_inn,
	c.supplier_kpp,
	c.object_name,
	c.org_name,
	c.org_inn,
	c.org_spz,
	org.id org_kgntv_contract,
	org.parentid grbsid,
	n.org_kgntv org_kgntv_notice,
	coalesce(n.joflag,0) joflag,
	s.org_kgntv org_kgntv_schedule,
	c.id,
	c.positionnumber,
	c.pricetype,
	c.executions_date,
	c_ais.lotid, --правки от 30.06.23 добавить lot id
	CASE
		WHEN c_ais.is_structured_form='f' THEN 'Нет'
		WHEN c_ais.is_structured_form='t' THEN 'Да'
		ELSE NULL
	END AS is_structured_form, --правки от 01.10.24
	c_ais.requestid
 From con c
 Inner Join nrpz.erc_dwh_organization_kgntv  org On c.customer_regnum = org.spz AND c.customer_inn!='7815000870' --16.02.24 убираем ИАЦ
 Left Join nrpz.contract_single_supp_reasons rs On rs.code_oos = c.singlecustomer And rs.actual = '1'
 Left Join (Select
				c.contractrnk rnk,
				c.lotid, --правки от 30.06.23 добавить lot id
				p.requestid,
   				is_structured_form --правки от 01.10.24
			From nrpz.erc_dwh_contract_kgntv_${srez_number}_6 c  
			Inner Join nrpz.erc_dwh_procedures_kgntv_${srez_number}_6 p On (c.lotid = p.lotuuid::int4)
			Group By c.contractrnk,c.lotid,is_structured_form,p.requestid
			)c_ais On (c_ais.rnk = c.rnk)
Left Join (Select 
				reqnum,  
				Case 
					When joflag = 0 Then org_kgntv 
					else org_kgntv_joflag end org_kgntv, 
				max(joflag) joflag  
			From nrpz.erc_${year}_start_notice 
			Group By reqnum,  Case When joflag = 0 Then org_kgntv else org_kgntv_joflag end
		   )n On (n.reqnum = c.notificationnumber)
Left Join (Select 
				Distinct positionnumber,
				org_kgntv
     		From nrpz.erc_${year}_schedule_pos
		   )s  On (s.positionnumber = c.positionnumber)
Where coalesce(n.reqnum,s.positionnumber) Is Not NULL Or schedule_year =20${year}
),
cn AS (Select 
				rnk,
				count(*) cnt_modif 
		   From 
				(Select 
					Distinct regnum rnk,
					versionnumber ,
					publishdate 
				 From nrpz.dwh_contract_notice_nrpz_acgz cn 
				 Where cn.name like '%contract' 
				 And cn.publishdate < to_date('${date2}','yyyy-mm-dd')
				 And cn.changetype_tag IS NOT null 
				)s 
			Group By rnk
			),
c_proc AS (Select DISTINCT ON (cp.regnum)
			cp.regnum rnk, 
			cp.publishdate, 
			Case 
				When cp.rejected_date Is Not Null Then 'Исполнение прекращено'
				When cp.currentcontractstage = 'E' Then 'Исполнение'
				When cp.currentcontractstage = 'ET' Then 'Исполнение прекращено'
				When cp.currentcontractstage = 'EC' Then 'Исполнение завершено'
				When cp.currentcontractstage = 'IN' Then 'Aннулировано'
				Else Null End stage, 
			Case 
				When cp.currentcontractstage = 'E' Then null 
				Else cp.executions_date end executions_date,
			cp.rejected_date, 
			cp.rejected_paid, 
			cp.rejected_reason, 
			Case 
				When cp.rejected_reason = '1' Then 'Соглашение сторон'
				When cp.rejected_reason = '2' Then 'Судебный акт'
				When cp.rejected_reason = '3' Then 'Односторонний отказ заказчика от исполнения контракта в соответствии с гражданским законодательством'
				When cp.rejected_reason = '4' Then 'Односторонний отказ поставщика (подрядчика, исполнителя) от исполнения контракта в соответствии с гражданским законодательством'
				Else Null End rejected_reason_name, 
			Case 
				When cp.penalties_type = 'F' Then 'Штраф'
				When cp.penalties_type = 'I' Then 'Пени'
				Else Null End penalties_type,
			Case
				When cp.penalties_party = 'C' Then 'Заказчик'
				When cp.penalties_party = 'S' Then 'Поставщик'
				Else Null End penalties_party,
			cp.penalties_amount
		 From nrpz.dwh_contract_notice_nrpz_acgz cp
		 Left Join (Select 
						Distinct regnum,
						id 
					From nrpz.dwh_contract_notice_nrpz_acgz
					Where name like '%contractProcedureCancel'
					)canc_ On (cp.id = canc_.id And cp.regnum = canc_.regnum)
		Where cp.name like '%contractProcedure' 
		And canc_.id Is Null 
		And cp.publishdate<to_date('${date}','yyyy-mm-dd')
		ORDER BY cp.regnum, cp.publishdate Desc
		),
prot AS (Select 
			p.purchasenumber As notificationnumber,
			max(p.protocoldate) As protocoldate_publ,
			max(p.signdate) protocoldate_sign
		  From nrpz.dwh_protocol_nrpz_acgz p
		  Left Join (Select 
						Distinct purchasenumber,
						protocolnumber,
						max(protocoldate) protocoldate
					 From nrpz.dwh_protocol_nrpz_acgz
					 Where type In ('ProtocolCancel','fcsProtocolCancel','epProtocolCancel')
					 group by purchasenumber, protocolnumber
					 )canc On (canc.protocolnumber = p.protocolnumber and canc.purchasenumber = p.purchasenumber and canc.protocoldate>=p.protocoldate) --изменение от 09-11-22 добавлено условие на дату
		  Where p.protocoldate < to_date('${date}','yyyy-mm-dd') 
		  and p.type In ('epProtocolEOK2020Final', 'epProtocolEF2020Final','epProtocolEZK2020Final',
						 'epProtocolEF2020SubmitOffers','epProtocolEZK2020FinalPart','fcsProtocolEFSingleApp',
						 'fcsProtocolEFSinglePart','fcsProtocolEF3','epProtocolEZP1','epProtocolEZP2',
						 'epProtocolEZK2','epProtocolEOK2','epProtocolEOK3','ProtocolOKD5','epProtocolEOK2020SecondSections','epProtocolEOK2020FirstSections',
                         'epProtocolEOKOU3','ProtocolZKAfterProlong') And canc.protocolnumber Is Null
		  Group By p.purchasenumber
		 ),
prot_one AS (Select 
			p.purchasenumber As notificationnumber,
			max(p.protocoldate)  protocoldate_publ, -- Изменение 24.08.22 protocoldate вместо publishdate так как берем Размещено в ЕИС а не на ЭП
			max(p.SIGNDATE) protocoldate_SIGN
		 From nrpz.dwh_protocol_nrpz_acgz p
		 Left Join (Select 
						Distinct purchasenumber,
						protocolnumber
					From nrpz.dwh_protocol_nrpz_acgz
					Where type In ('ProtocolCancel','fcsProtocolCancel','epProtocolCancel')
					)canc On (canc.protocolnumber = p.protocolnumber And canc.purchasenumber = p.purchasenumber)
		 Where p.protocoldate < to_date('${date}','yyyy-mm-dd') 
		 And p.type In ('epProtocolEOKOUSingleApp','epProtocolEOKDSingleApp','epProtocolEOKSingleApp','epProtocolEZP1','epProtocolEZP2')
		 And canc.protocolnumber Is Null
		Group By p.purchasenumber
		),
mess AS (Select 	contract_rnk rnk,
			successdate  -- считать от успешной даты  первой отправки сведений на ЕИС/ Письмо от 05.08.2020 считается от успешной отправки сведений в ЕИС
From nrpz.erc_${year}_contract_mess),
peva AS 
(Select Distinct a.purchasenumber
             From 
               (Select purchasenumber, max(protocoldate) protocoldate, protocolnumber 
                From nrpz.dwh_protocol_nrpz_acgz
                Where type in ('fcsProtocolDeviation', 'fcsProtocolEvasion', 'epProtocolEvasion', 'epProtocolDeviation') -- epProtocolDeviation добавлен с 1ого квартала 2022
                And protocoldate < to_date('${date}','yyyy-mm-dd')
                Group by purchasenumber, protocolnumber
                )a
            Left join 
                (Select purchasenumber, max(protocoldate) protocoldate_cans, protocolnumber protocolnumber_cans 
                 From nrpz.dwh_protocol_nrpz_acgz
                 Where type in ('epProtocolCancel', 'fcsProtocolCancel', 'epProtocolEvDevCancel')-- epProtocolEvDevCancel добавлен с 1ого квартала 2022
                 And protocoldate < to_date('${date}','yyyy-mm-dd') 
                 Group by purchasenumber, protocolnumber
                )b On a.purchasenumber = b.purchasenumber And a.protocolnumber = b.protocolnumber_cans
            Where b.protocolnumber_cans is null
            Or (a.protocolnumber = b.protocolnumber_cans and protocoldate_cans < protocoldate)
		 )
Select 
	Distinct 
    coalesce(n_first.positionnumber, n_last.positionnumber) positionnumber,
	n_last.pricetype,
	n_first.rnk,
	n_first.rnk_number,
	n_first.ikz,
	n_first.grbsid,
	n_first.signdate, 
	n_first.publishdate publishdate_first,
	n_last.publishdate publishdate_last,
	n_first.versionnumber versionnumber_first,
	n_last.versionnumber versionnumber_last,
	n_first.notificationnumber,
	n_first.lotnumber,
	n_first.sop_name,
	n_last.singlecustomer_name,
	n_first.protocoldate,
	n_first.price,
	n_last.price price_cur,
	coalesce(c_proc.stage, n_last.stage) stage,
	coalesce(n_first.executions_date, c_proc.executions_date)executions_date,
	c_proc.rejected_date, 
	c_proc.rejected_paid, 
	c_proc.rejected_reason, 
	c_proc.rejected_reason_name,
	c_proc.penalties_type,
	c_proc.penalties_party,
	c_proc.penalties_amount,			
	n_first.supplier_fullname supplier_fullname,
	n_first.supplier_inn,
	n_first.supplier_kpp,
	n_first.object_name object_name,
	n_first.org_name,
	n_first.org_inn,
	n_first.org_spz,
	n_first.org_kgntv_contract,
	n_first.org_kgntv_notice,
	n_first.org_kgntv_schedule,
	Coalesce(n_first.org_kgntv_contract,n_first.org_kgntv_schedule, n_first.org_kgntv_notice) org_kgntv,
	n_first.joflag,
	prot.protocoldate_publ,
	prot.protocoldate_sign,
	prot_one.protocoldate_publ protocoldate_one_publ,
	prot_one.protocoldate_sign protocoldate_one_sign,
	mess.successdate firstnoticesuccesdate,
	Case 
		When regexp_like(Case When n_first.singlecustomer_name Is Null Then n_last.singlecustomer_name else n_first.singlecustomer_name end,'(^Часть 1 пункт (4|5|23|42|44|46) статьи 93)') Then 0 --Правки от 30.06.23 убран пункт 45
		Else 1 End flag_16,
	coalesce(cn.cnt_modif,0) cnt_modif,
	Case 
		When peva.purchasenumber Is Not Null Then 1 
		Else 0 end flag_evasion,
	n_first.lotid, --правки от 30.06.23 добавить lot id
	n_first.is_structured_form,
	n_first.requestid
From notice n_first  
Inner Join notice n_last On (n_last.notice = 1 And n_first.rnk = n_last.rnk)
Left JOIN cn On (n_first.rnk = cn.rnk)
Left Join c_proc On c_proc.rnk = n_first.rnk        
Left JOIN prot On (prot.notificationnumber = n_first.notificationnumber)      
Left JOIN prot_one On (prot_one.notificationnumber = n_first.notificationnumber)
Left JOIN mess On mess.rnk = n_first.rnk
Left JOIN peva On (peva.purchasenumber = n_first.notificationnumber) -- изменение от 06.12.21
Where n_first.notice = 0;
