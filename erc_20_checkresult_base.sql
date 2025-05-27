--Жалобы
Truncate Table nrpz.erc_${year}_checkresult_base;
Insert into nrpz.erc_${year}_checkresult_base
  Select 
	ch.com_number,
	ch.check_number,
	ch.reqnum,
	ch.chec_date,
	ch.chec_pres_date,
	ch.result,
	ch.prescriptionnumber,
	complaint_publishdate,
	org_name,
	org_inn,
	org_spz,
	ch.ttpoperator
From 
	(Select 
		Case
			When ch.complaint_regnumber Is Not Null Then ch.complaint_regnumber else ch.COMPLAINTNUMBER end COM_NUMBER, 
		ch.purchasenumber reqnum,
		Case
			When ch.regnumber Is Not Null Then ch.regnumber When length(ch.checkresultnumber)>=3 Then ch.checkresultnumber Else Null End check_number,
		ch.publishdate chec_date,				
		ch.prescriptiondate chec_PRES_DATE, --дата предписания			
		ch.RESULT,
		ch.prescriptionnumber,		
		ch.complaint_publishdate,
		ch.checksubjects_fullname org_name,
		ch.checksubjects_inn org_inn, /*не всегда есть*/
		coalesce(ch.checksubjects_regnum,org.spz) org_spz, /*не всегда есть*/
		Row_number() OVER (Partition By 
							Case 
							When ch.complaint_regnumber Is Not Null Then ch.complaint_regnumber Else ch.COMPLAINTNUMBER	End,
							ch.purchasenumber,
							ch.checksubjects_regnum,
							ch.checksubjects_inn,
							Case 
							When ch.regnumber Is Not Null Then ch.regnumber When length(ch.checkresultnumber)>=3 Then ch.checkresultnumber Else Null End 
							Order By ch.publishdate Desc,ch.RESULT
							) rn,
		nullif(ch.ttpoperator, '') ttpoperator
	From nrpz.dwh_checkresult_nrpz_acgz  ch
	Inner Join (Select 
					Distinct reqnum
				From nrpz.erc_${year}_start_notice
				)st On st.reqnum = ch.purchasenumber
	left Join nrpz.erc_dwh_organization_kgntv org On org.inn = ch.checksubjects_inn
	Where 
		ch.NAME Not In('ns2:checkResultCancel', 'checkResultCancel')
		And (ch.publishdate>=To_date('${budget_date}', 'YYYY-MM-DD'))  --дата принятия бюджета СПб
		And (ch.publishdate<To_date('${date}','yyyy-mm-dd')) 
		And coalesce(ch.RESULT,'0') Not In  ('COMPLAINT_NO_VIOLATIONS','NO_VIOLATIONS','COMPLAINT_NO_VIOLATIONS_LAW')
	)ch
left Join 
		(Select 
			Distinct Case When regnumber Is Not Null Then regnumber When length(checkresultnumber)>=3 Then checkresultnumber Else Null End check_number 
		From nrpz.dwh_checkresult_nrpz_acgz 
		Where 
			publishdate>= To_date('${budget_date}', 'YYYY-MM-DD') -- дата принятия бюджета СПб
			And NAME In ('checkResultCancel','ns2:checkResultCancel') -- отмененные жалобы не должны учитываться
			And publishdate< To_date('${date}','yyyy-mm-dd') -- ограничение на дату среза
		)ch_canc On ch_canc.check_number = ch.check_number
Where
	ch.rn = 1 
	-- 14.03.24 And coalesce(ch.RESULT,0) Not In  ('COMPLAINT_NO_VIOLATIONS','NO_VIOLATIONS','COMPLAINT_NO_VIOLATIONS_LAW')  -- жалобы чей статус "Не обоснована" мы не учитываем в рейтинге 08.02.2022 добавлен COMPLAINT_NO_VIOLATIONS_LAW 
	And ch_canc.check_number Is Null -- ограничение чтобы не взять отмененные жалобы
    And com_number is not null -- 14.10.2022 попадает ошибочная жалоба
Order By 
	ch.COM_NUMBER,
	ch.check_number;


Delete From nrpz.erc_${year}_checkresult_base
Where com_number in (Select com_number 
                     From nrpz.erc_${year}_checkresult_base
                     Group By com_number
                     Having Count(*)>1)
And check_number is null;--удаляем дублирующиеся жалобы



delete 
FROM nrpz.erc_${year}_checkresult_base
where ttpoperator is not NULL OR ttpoperator = ''; --01.10.24 где субъект контроля "Оператор электронной площадки"


DELETE FROM nrpz.erc_${year}_checkresult_base
WHERE com_number in ('202500100161005696', '202500100161005607'); -- 01.04.25 правка 5.2: исключить 2 жалобы

DELETE FROM nrpz.erc_${year}_checkresult_base
WHERE com_number in ('202500100161005696', '202500100161005607'); -- 01.04.25 правка 5.2: исключить 2 жалобы
