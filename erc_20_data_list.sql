-- Детализация
truncate table nrpz.erc_${year}_data_list;
insert into nrpz.erc_${year}_data_list
select	eo.orgtitle grbstitle, --ГРБС
		rl.ORG_NAME, --Заказчик
		rl.ORG_KGNTV, --Заказчик ID
		rl.PLANNUMBER, --Реестровый номер ПГ
		rl.VERSIONNUMBER, --Версия ПГ
		rl.PUBLISHDATE, --Дата публикации ПГ
		rl.POSITIONNUMBER, --Реестровый номер позиции ПГ
		rl.IKZ, --ИКЗ из ПГ
		rl.NMC_SCHEDULE, --НМЦ ПГ
		rl.PURCHASECANCELED, --позиция отменена в ПГ
		rl.CNT_MODIF_PG, --Число изменений позиции в ПГ
		rl.REQNUM, --Реестровый номер извещения
		rl.PUBLISHDATE_REQNUM,--Дата публикации извещения
		rl.SOP_NAME_REQNUM,--Способ определения поставщика в извещении
		rl.IKZ_REQNUM,--икз из извещения
		rl.JOFLAG_ORG_NAME, --Организатор совместной закупки 
		rl.JOFLAG, --Часть совместной закупки 
		rl.NMC_REQNUM, --НМЦ в извещении
		rl.NMC_JOFLAG, --НМЦ совместной закупки 
		rl.LOTNUMBER, --Номер лота
		rl.FLAG_COMP_REQNUM, --Конкурентный СОП 
		rl.OBJECT_NAME_REQNUM, --Объект закупки в извещении
		rl.CNT_MODIF_REQNUM, --Число изменений извещения
		rl.RNK, --Реестровый номер контракта
		rl.SIGNDATE, --Дата подписания контракта
		rl.PUBLISHDATE_CON, --Дата публикации контракта
		rl.SOP_NAME_CON, --Способ определения поставщика в контракте
		rl.ONEEX_CON, --Обоснование у ед.поставщика
		rl.PROTOCOLDATE_CON, --Дата протокола основания
		rl.CK_FIRST, --Цена контракта
		rl.CK_LAST, --Цена контракта на отчетную дату
		rl.STAGE_CON, --Состояние контракта
		rl.PLAN_EXECUTION_DATE_CON, --Плановая дата исполнения контракта из контракта
		rl.EXECUTIONS_DATE, --Дата исполнения
		rl.REJECTED_DATE,--Дата растордения
		rl.PENALTIES_PARTY, --Штраф наличие		
		rl.SUPPLIER_FULLNAME, --Поставщик
		rl.SUPPLIER_INN,  --Поставщик ИНН
		rl.OBJECT_NAME_CON, --Объект закупки в контракте
		rl.PROTOCOLDATE_PUBL, -- Дата публикации протокола
		rl.PROTOCOLDATE_SIGN, -- Дата подписания протокола
		rl.PROTOCOLDATE_ONE_PUBL, --Дата публикации 1-ого протокола
		rl.PROTOCOLDATE_ONE_SIGN, --Дата подписания 1-ого протокола
		rl.FIRSTNOTICESUCCESDATE, --Первая успешная попытка отправки сведений по контракту
		case when rl.purchasenumber_rn = 1 then 1 else 0 end purchasenumber_rn,
		rl.pricetype, --Тип определения цены контракта
		rl.requestid, --ID закупки
		rl.CNT_MODIF_CON, --Число изменений по контракту
	    rl.flag_evasion, --Флаг отклонения/отказа
	    rl.type_, --Тип
	    rl.lotid, -- ID лота
		rl.is_structured_form, --электронный контракт сформирован в структурированном виде
		-- F2
		case when rl.flag_comp_reqnum = 1 and (rl.joflag = 1 and rl.org_kgntv_joflag not in (1412, 592) or rl.joflag =0) then 1 else 0 end erc_f2_2,
		case when rl.flag_comp_reqnum = 1 and rl.flag_cans_reqnum = 1 and (rl.joflag = 1 and rl.org_kgntv_joflag not in (1412, 592) or rl.joflag =0) then 1 else 0 end  erc_f2_1,
		--F3N1
		case when rl.flag_comp_reqnum = 1 and rl.rnk is not null then 1 else 0 end f3n1,
		--case when rl.rnk is not null and co.rnk is null then 1 else 0 end f3n2,
		--F9N2
		case when rl.flag_comp_reqnum = 1 
		and rl.sop_name_reqnum is not null
		--and (lower(rl.sop_name_reqnum) like '%аукцион%' or lower(rl.sop_name_reqnum) like '%конкурс%'  or lower(rl.sop_name_reqnum) like '%котировок%')
		and (case when org_kgntv_joflag in (1412,592)  and joflag = 1 then 1 else 0 end)=0 then 1 else 0 end f9n2, -- 01.01.25 добавлен id=592 (дирекция по закупкам Комитета по здравоохранению)
		--F10N2
		case when rl.flag_comp_reqnum = 1 
		and rl.sop_name_reqnum is not null
		and (case when org_kgntv_joflag in (1412, 592) and joflag = 1 then 1 else 0 end)=0 then 1 else 0 end f10n2, 
		--F11
		case when rl.flag_comp_reqnum = 1 and rl.rnk is not null and oneex_con is not null then 1 else 0 end f11n1,
		case when rl.flag_comp_reqnum = 1 and rl.rnk is not null then 1 else 0 end f11n2,
		--F14
		case when rl.flag_comp_reqnum = 1 and rl.rnk is not null 
				 and (case when rl.rnk is not null and rl.contract_project_number is not null and rl.contract_price_changed_supplier_protocol is true and rl.justification_contract_price_change = '10' then 1 else 0 end)=0
				 and (rl.pricetype is null or (case when  rl.pricetype in ('Максимальное значение цены контракта') then 1 else 0 end)=0) then rl.nmc_reqnum else 0 end f14n1,
		case when rl.flag_comp_reqnum = 1 and rl.rnk is not null 
				 and (case when rl.rnk is not null and rl.contract_project_number is not null and rl.contract_price_changed_supplier_protocol is true and rl.justification_contract_price_change = '10' then 1 else 0 end)=0
				 and (rl.pricetype is null or (case when  rl.pricetype in ('Максимальное значение цены контракта') then 1 else 0 end)=0) then ck_first else 0 end f14n2,
		--F15
		case  when rl.flag_comp_reqnum = 1 and rl.rnk is not null and  rl.flag_evasion = 0 and  lr.ikz_reqnum is not NULL and 
			  case 
              --Пункт 1 и 2 (2)
                 When rl.protocoldate_publ Is Null And rl.protocoldate_sign Is Null And rl.protocoldate_One_publ Is Null And rl.protocoldate_One_SIGN Is Null Then 0						
                 When (rl.sop_name_reqnum Like '%Открытый конкурс%')
                    And ((d.purchasenumber Is Not Null  And rl.nmc_reqnum >1000 ) or (rl.nmc_reqnum >250000000 ))And rl.Oneex_cOn Is Not Null
                          And (date_trunc('day', rl.signdate) - date_trunc('day',rl.protocoldate_publ)) > (10 || ' days')::interval
                          And date_trunc('day',rl.signdate) <= 
                                                    (
                                                     Select min(t.date_) From sppr.work_days_of t
                                                     Where t.date_>=(
                                                     Select min(t.date_)+20 From sppr.work_days_of t Inner Join sppr.work_days_of t1 On (t.date_>t1.date_ And t.nm=t1.nm+17) --05.07.23 8 дней 
                                                     Where t1.date_=date_trunc('day',rl.protocoldate_publ))
                                                    )
                 Then 0 
                 When (rl.sop_name_reqnum Like '%лектронный аукцион%')
                    And ((d.purchasenumber Is Not Null AND d.num_type = 0 And rl.nmc_reqnum >1000 ) or (rl.nmc_reqnum >250000000 ))And rl.Oneex_cOn Is Not Null
                          And (date_trunc('day', rl.signdate) - date_trunc('day',rl.protocoldate_publ)) > (10 || ' days')::interval 
                          And date_trunc('day',rl.signdate) <= 
                                                    (
                                                     Select min(t.date_) From sppr.work_days_of t
                                                     Where t.date_>=(
                                                     Select min(t.date_)+20 From sppr.work_days_of t Inner Join sppr.work_days_of t1 On (t.date_>t1.date_ And t.nm=t1.nm+17) --05.07.23 8 дней 
                                                     Where t1.date_=date_trunc('day',rl.protocoldate_publ))
                                                    )
                 Then 0  
              --Пункт 3
                 When (rl.sop_name_reqnum Like '%лектронный аукцион%' or
                        rl.sop_name_reqnum Like '%Открытый конкурс%')
                 And (date_trunc('day', rl.signdate) - date_trunc('day',rl.protocoldate_publ) > (10 || ' days')::interval) And  
                          date_trunc('day',rl.signdate) <= 
                 (
                  Select min(t.date_)
                    From sppr.work_days_of t Inner Join sppr.work_days_of t1 On (t.date_>t1.date_ And t.nm=t1.nm+12)
                    Where t1.date_>=  (Select min(date_)
                    From sppr.work_Days_all
                    Where DATE_ >= (date_trunc('day',rl.protocoldate_publ)) And type='1')
                 )                 
                 Then 0		
                 When  (lower(rl.sop_name_reqnum) Like 'запрос котировок в электронной форме%')
                 and date_trunc('day',rl.signdate)>=date_trunc('day',rl.protocoldate_publ) And
                 date_trunc('day',rl.signdate) = --17.01.24 изменено условие <=
                 ( SELECT d.date_ FROM sppr.work_days_of d WHERE d.nm =(
                  Select case when date_trunc('day',rl.protocoldate_publ)<>min(t1.date_) then min(t.nm)-1 else min(t.nm) end
                    From sppr.work_days_of t Inner Join sppr.work_days_of t1 On (t.date_>t1.date_ And t.nm=t1.nm+3)
                    Where t1.date_>=  (Select min(date_)
                    From sppr.work_Days_all
                    Where DATE_ >= (date_trunc('day',rl.protocoldate_publ)) And type='1'))
                 )
				 Then 0 					
			Else 1 END = 1		
		Then 1 Else 0 End f15n1,
		case when rl.flag_comp_reqnum = 1 and rl.rnk is not null and rl.flag_evasion = 0 and lr.ikz_reqnum is not null then 1 else 0 end f15n2,
		rl.flag_cans_reqnum,
		rl.contract_project_number,
		CASE 
			WHEN rl.contract_price_changed_supplier_protocol IS TRUE THEN 'Да'
			ELSE 'Нет'
		END contract_price_changed_supplier_protocol,
		CASE 
			WHEN rl.justification_contract_price_change ='1' THEN 'Не указано'
			WHEN rl.justification_contract_price_change ='2' THEN 'Изменение более чем на 10% стоимости планируемых к приобретению товаров, работ, услуг, выявленные в результате подготовки к размещению конкретного заказа'
			WHEN rl.justification_contract_price_change ='3' THEN 'Изменение планируемых сроков приобретения товаров, работ, услуг, способа размещения заказа, срока исполнения контракта.'
			WHEN rl.justification_contract_price_change ='4' THEN 'Отмена заказчиком, уполномоченным органом предусмотренного планом-графиком размещения заказа.'
			WHEN rl.justification_contract_price_change ='5' THEN 'Образовавшаяся экономия от использования в текущем финансовом году бюджетных ассигнований'
			WHEN rl.justification_contract_price_change ='6' THEN 'Возникновение непредвиденных обстоятельств'
			WHEN rl.justification_contract_price_change ='7' THEN 'Выдача предписания уполномоченного органа исполнительной власти об устранении нарушения законодательства РФ'
			WHEN rl.justification_contract_price_change ='8' THEN 'Изменение по результатам обязательного общественного обсуждения'
			WHEN rl.justification_contract_price_change ='9' THEN 'Отмена по результатам обязательного общественного обсуждения'
		END justification_contract_price_change
from nrpz.erc_${year}_list_contract rl
join nrpz.erc_dwh_organization_kgntv dok on dok.id = rl.org_kgntv
join nrpz.erc_dwh_organization_kgntv dokgrbs on dokgrbs.id = dok.parentid
join nrpz.ERC_ORGANIZATION eo on eo.spz = dokgrbs.spz
left join (select min(signdate)signdate, 
				  min(case when type_ = 'eis' then publishdate_con else signdate end) publishdate_con, 
				  ikz_reqnum 
		   from nrpz.erc_${year}_list_contract rl  
		   where ikz_reqnum is not null group by ikz_reqnum) lr on rl.ikz_reqnum=lr.ikz_reqnum 
		   														and rl.signdate=lr.signdate 
		   														and (case when rl.type_ = 'eis' then rl.publishdate_con else rl.signdate end)=lr.publishdate_con
--left join nrpz.erc_${year}_contract_oneex co on co.rnk = rl.rnk
left join (Select  purchasenumber, 								
					min(CASE WHEN title = 'Протокол подведения итогов определения поставщика (подрядчика, исполнителя)' THEN 0
					WHEN title = 'Протокол рассмотрения и оценки первых частей заявок на участие в открытом конкурсе в электронной форме' THEN 1
					ELSE 2 END) AS num_type							
			From nrpz.erc_${year}_demand 							
			Where (cnt_all=0 or cnt_adm=0) 
			AND title in ('Протокол подведения итогов определения поставщика (подрядчика, исполнителя)',
							  'Протокол рассмотрения и оценки первых частей заявок на участие в открытом конкурсе в электронной форме',
							  'Протокол рассмотрения и оценки вторых частей заявок на участие в открытом конкурсе в электронной форме')
			GROUP BY purchasenumber) d On rl.reqnum=d.purchasenumber;

