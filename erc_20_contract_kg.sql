--малые закупки ЭМ и АИС ГЗ

Truncate Table nrpz.erc_${year}_contract_kg;
Insert into nrpz.erc_${year}_contract_kg
Select 
	c.contractrnk rnk,
	d.ikz ikz,
	d.orgid org_kgntv,
	c.contractsigndate signdate, 
	c.contractoneexecreason singlecustomer_name,
	d.f_productprice,
	coalesce(c.contractsigningprice,c.contractfullprice) price, -- так как есть контракты с пустой ценой контракта на момент заключения берем и текущую
	c.contractfullprice price_cur,
	Case
		When c.contractrejectdate Is Not Null Then 'Исполнение прекращено'
		When c.contractactualexecdate Is Not Null Then 'Исполнение завершено'
		Else 'Исполнение' 
		End stage,
	c.contractactualexecdate executions_date,
	Case 
		When date_trunc('day',c.contractrejectdate)>to_date('${date}','YYYY-MM-DD') Then Null 
		Else c.contractrejectdate End rejected_date, 
	Case 
		When pen.id Is Not Null Then 'пени' 
		Else Null End penalties_type,
	Case 
		When pen.id Is Not Null Then 'поставщик' 
		Else Null End penalties_party,
	c.contractplaneexecdate executionperiod_end,
	c.contractsubject object_name,
	c.customername org_name,
	c.customerinn org_inn,
	c.grbsid,
	c.ordertypename placingway_name,
	c.is_concluded_in_e_shop,
	c.lotid,
	d.requestid,
	Case 
		When Length(c.contractrnk)>13 Then 1 
		Else 0 End flag_16,
	mess.successdate firstnoticesuccesdate,
	CASE
		WHEN c.is_structured_form='f' THEN 'Нет'
		WHEN c.is_structured_form='t' THEN 'Да'
		ELSE NULL
	END AS is_structured_form --правки от 01.10.24
From nrpz.erc_dwh_contract_kgntv_${srez_number}  c 
Inner Join nrpz.erc_dwh_proced_detail_kg_${srez_number} d On d.lotuuid::int4=c.lotid And customerid Not In (3039,2913,31344,2998,3020,2901,3024,2994,7817,3774,29714,3127,3128,3132,3133,2147,3011,1556 )
Left Join nrpz.erc_${year}_schedule_pos sch On sch.ikz = d.pg_ikz AND sch.plannumber=d.pg_rn --  от 27.01.2025  добавлено условие sch.plannumber=d.pg_rn, т.к. есть разные ППГ, но один ИКЗ ikz = '242780702876978070100100010000000244'
Left Join (Select distinct id From sppr.dwh_contract_penalty_kgntv Where reason_id In (1,3)) pen On pen.id = c.contractid
Left Join nrpz.erc_${year}_contract cc On cc.rnk = c.contractrnk
Left Join (Select 
				contract_rnk rnk,
				successdate  -- изменение с successdate на date_ от 14/08/2017 терехова -- от 14.11 считать от успешной даты  первой отправки сведений на еис 
		   From nrpz.erc_${year}_contract_mess 
		   )mess On mess.rnk = c.contractrnk
Where cc.rnk Is Null 
	And d.pg_rn Like '20${year}%' 
	And regexp_Like(contractoneexecreason,	'(^Часть 1 пункт (4|5|23|33|42|44|46) статьи 93)') -- правки от 30.06.23 убран 45 пункт
	And c.contractsigndate < To_date('${date}','yyyy-mm-dd') And c.contractsigndate >= to_date('${start_date}','yyyy-mm-dd') And C.contractcreatedate < To_date('${date3}','yyyy-mm-dd')
;		
	
Insert Into nrpz.erc_${year}_contract_kg 
Select 
		c.contractrnk rnk,
		d.ikz ikz,
		d.orgid org_kgntv,
		c.contractsigndate signdate, 
		c.contractoneexecreason singlecustomer_name,
		d.f_productprice,
        coalesce(c.contractsigningprice,c.contractfullprice) price, -- так как есть контракты с пустой ценой контракта на момент заключения берем и текущую
		c.contractfullprice price_cur,
		Case 	When c.contractrejectdate Is Not Null Then 'Исполнение прекращено'
				When c.contractactualexecdate Is Not Null Then 'Исполнение завершено'
				else 'Исполнение' 
		End stage,
		c.contractactualexecdate executions_date,
		Case When date_trunc('day', c.contractrejectdate)>to_date('${start_date}','yyyy-mm-dd') Then Null Else c.contractrejectdate End rejected_date, 
		Case When pen.id Is Not Null Then 'пени' Else Null End penalties_type,
		Case When pen.id Is Not Null Then 'поставщик' Else Null End penalties_party,
		c.contractplaneexecdate executionperiod_end,
		c.contractsubject object_name,
		c.customername org_name,
		c.customerinn org_inn,
		c.grbsid,
		c.ordertypename placingway_name,
		c.is_concluded_in_e_shop,
		c.lotid,
		d.requestid, Case When length(c.contractrnk)>13 then 1 Else 0 End flag_16,mess.successdate firstnoticesuccesdate,
	    CASE
		 WHEN c.is_structured_form='f' THEN 'Нет'
		 WHEN c.is_structured_form='t' THEN 'Да'
		 ELSE NULL
	    END AS is_structured_form --правки от 01.10.24
From sppr.dwh_contract_kgntv  c 
Join sppr.dwh_procedures_detailed_kgntv d On d.lotuuid=c.lotid And customerid  not In (3039,2913,31344,2998,3020,2901,3024,2994,7817,3774,29714,3127,3128,3132,3133,2147,3011,1556 )
Left Join nrpz.erc_${year}_schedule_pos sch On sch.ikz = d.pg_ikz AND sch.plannumber=d.pg_rn --  от 27.01.2025  добавлено условие sch.plannumber=d.pg_rn, т.к. есть разные ППГ, но один ИКЗ ikz = '242780702876978070100100010000000244'
Left Join (Select distinct id From sppr.dwh_contract_penalty_kgntv Where reason_id In (1,3)) pen On pen.id = c.contractid
Left Join nrpz.erc_${year}_contract cc On cc.rnk = c.contractrnk
Left Join
	(
		Select contract_rnk rnk,successdate  -- изменение с successdate на date_ от 14/08/2017 терехова -- от 14.11 считать от успешной даты  первой отправки сведений на еис 
			From nrpz.erc_${year}_contract_mess 
	)mess On mess.rnk = c.contractrnk
Where cc.rnk Is Null And d.pg_rn Like '20${year}%' 
		and regexp_Like(contractoneexecreason,	'(^Часть 1 пункт (4|5|23|33|42|44|46) статьи 93)') -- правки от 30.06.23 убран 45 пункт
		and c.contractsigndate < To_date('${date}','yyyy-mm-dd')  And c.contractsigndate >= to_date('${start_date}','yyyy-mm-dd')
        And c.contractrnk not In (Select distinct rnk From nrpz.erc_${year}_contract_kg) And C.contractcreatedate < To_date('${date3}','yyyy-mm-dd')
        ;

delete From nrpz.erc_${year}_contract_kg
Where 
org_inn In ('7822002853', '7806143720', '7806143737', '7802215268', '7802215250', '7817044400', '7819029196', '7805283280', '7807053821', '7807053839', '7805283273', '7810293894', '7810293904', '7804169401', '7804169391', '7820038893', '7843000046', '7816226502', '7816226189', '7814143064', '7813188464', '7820038903', '7814143057', '7843000039', '7842000050', '7839000318', '7842000068', '7811139119', '7801238167', '7811139084', '7820073802', '7801682580', '7817106590', '7842181030', '7819042648', '7813644519', '7839127850', '7805765622', '7805765615', '7807241381', '7807241374', '7810795943', '7811747981', '7806573056', '7804670495', '7802708190', '7802708182', '7802708150', '7811747935', '7806573031', '7804670382', '7804670431', '7804670375', '7811747999', '7816706900', '7816706971', '7814776557', '7811747974', '7816706989', '7814776500', '7811747928', '7814776564', '7816706925', '7801682598', '7819029206')
;

delete From nrpz.erc_${year}_contract_kg
Where org_kgntv::int4 In (2167,498,1725,3064,2981,1030,3097,2398)
;

delete From  nrpz.erc_${year}_contract_kg Where grbsid = 1894; --удалаяем избирательную коммисию


--добавляем по пункту в erc_${year}_contract_kg
Insert Into nrpz.erc_${year}_contract_kg 
Select 
        c.rnk,
		c.ikz,
        c.org_kgntv,
		c.signdate,
		c.oneex_con,
        c.nmc_reqnum,
        c.ck_first,
        c.ck_last,
        c.stage_con,
		c.executions_date,
		c.rejected_date, 
		Case When c.penalties_type = 'Штраф' Then 'пени' Else Null End penalties_type, --18.07.23 для того, что поле было одной длины
		c.penalties_party,
		c.plan_execution_date_con,
		c.object_name_con,
		c.org_name_con,
		c.org_inn_con,
		c.grbsid,
        c.sop_name_con,
        null as is_concluded_in_e_shop,
		k.lotid,
		k.requestid, 
        c.flag_16,
        c.firstnoticesuccesdate,
        c.is_structured_form,
        c.REQNUM,
        c.PUBLISHDATE_REQNUM
From nrpz.erc_${year}_list_contract c
Join nrpz.erc_dwh_contract_kgntv_${srez_number} k on c.rnk = k.contractrnk
Where sop_name_reqnum in ('Закупка товара у единственного поставщика на сумму, предусмотренную частью 12 статьи 93 Закона № 44-ФЗ',
						  'Закупка, осуществляемая в соответствии с частью 12 статьи 93 Закона № 44-ФЗ') 
And rnk is not null;

----удаляем по пункту из erc_${year}_list_contract
Delete From nrpz.erc_${year}_list_contract
Where sop_name_reqnum in ('Закупка товара у единственного поставщика на сумму, предусмотренную частью 12 статьи 93 Закона № 44-ФЗ',
						  'Закупка, осуществляемая в соответствии с частью 12 статьи 93 Закона № 44-ФЗ') 
And rnk is not null;
