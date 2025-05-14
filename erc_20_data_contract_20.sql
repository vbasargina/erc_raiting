-- Детализация контракты 17
truncate table nrpz.erc_${year}_data_contract_${year};
insert into nrpz.erc_${year}_data_contract_${year} 
select  distinct 
		eo.orgtitle grbstitle, --ГРБС
		sc.org_kgntv, --ID заказчика
		org_name, -- Заказчик
		sc.rnk, -- РНК
		plan_execution_date_con, --Плановая дата исполнения
		executions_date, --Дата исполнения
		rejected_date, --Дата расторжения
		penalties_party, --Штраф
		ck_first, --Первоначальная Цена контракта
		flag_comp_reqnum flag_3_n1, --Учитывается в числителе показателя 3, 4
		case when co.rnk is not null then 1 else 0 end flag_oneex, --Контракт с ед. поставщиком
		ck_last, --Текущая Цена контракта
		pay_.pay_, --Платеж на отчетную дату
		pay_.execdocdate, --Дата платежа
		sc.oneex_con, --Основание у ед.источника
		sc.object_name, --Объект закупки
		sc.sop_name, --Способ определения поставщика
		sc.lotid AS lotuuid, --ID лота
		sc.requestid,  
		FIRSTNOTICESUCCESDATE,
		flag_16,
		sc.work_days, 
		sc.is_concluded_in_e_shop,
		sc.is_structured_form,
		sc.reqnum,
		--F17
		case when date_trunc ('day', sc.plan_execution_date_con ) < to_date('${date}','DD-MM-YYYY') -- конец квартала
						and( case 
									when sc.executions_date is not null  and date_trunc ('day', sc.executions_date ) > date_trunc ('day', sc.work_days ) 	and	(coalesce(penalties_party,' ')not like '%оставщик%')
										and coalesce(pay_.pay_,-100)<coalesce(sc.ck_last,0)
										then 1
									when sc.executions_date is null and date_trunc ('day',sc.work_days) < date_trunc ('day', sc.rejected_date )
										and	(coalesce(penalties_party,' ')not like '%оставщик%') and coalesce(pay_.pay_,-100)<coalesce(sc.ck_last,0) -- изменение от 06.12.2021
	                                    then 1
									when sc.executions_date is null and sc.rejected_date is null and coalesce(pay_.pay_,-100)<coalesce(sc.ck_last,0)
										and	(coalesce(penalties_party,' ')not like '%оставщик%')
	                                    then 1
									 when sc.executions_date is null and sc.rejected_date is null and sc.ck_last is null
										then 1
									else 0 end = 1
						) then 1 else 0 end flag_n1,
		case when date_trunc ('day', sc.plan_execution_date_con )< to_date('${date}','DD-MM-YYYY') and sc.rnk is not null
	    then 1 else 0 end flag_n2,
	    -- F16
	    CASE -- в структурированном виде
	    	WHEN sc.is_structured_form = 'Да' AND  sc.flag_16 = 1  and sc.rnk is not NULL
	    	     and ( select  sum ( days.TYPE::int2 )
					   from sppr.work_days_all days
					   where days.date_ >= date_trunc ('day',sc.SIGNDATE+ interval '1 day')
					   and days.date_ < date_trunc ('day',sc.FIRSTNOTICEsuccesDATE)) >= 3 then 1
			-- не в структурированном виде		   
			WHEN sc.is_structured_form = 'Нет' AND  sc.flag_16 = 1  and sc.rnk is not NULL		   
                  and ( select  sum ( days.TYPE::int2 )
						from sppr.work_days_all days
						where days.date_ > date_trunc ('day',sc.SIGNDATE) 
						and days.date_ < date_trunc ('day',sc.FIRSTNOTICEsuccesDATE)) >= 5 then 1 
        else 0 end f16n1,		    
	   	case when ( sc.flag_16 = 1) and sc.rnk is not null then 1 else 0 end f16n2,
		-- F3N2	
	 	case when co.rnk is null and coalesce(sc.sop_code_reqnum,'0') not in ('EZTP20') and  sc.is_concluded_in_e_shop is null and coalesce(sc.oneex_con,'0')
		not in ('Закупка товара в случаях, предусмотренных пунктами 4 и 5 части 1 статьи 93 Федерального закона, в электронной форме с использованием электронной площадки',
				'Пункт 4 и 5 части 1 статьи 93 -  Закупка товара в случаях, предусмотренных пунктами 4 и 5 части 1 статьи 93 Федерального закона, в электронной форме с использованием электронной площадки') then 1 else 0 end f3_n2,    
        sc.SIGNDATE
from 
		(select sop_code_reqnum,rejected_date, executions_date,plan_execution_date_con, rnk , org_kgntv, penalties_party, org_name, ck_first,coalesce(flag_comp_reqnum,'0') flag_comp_reqnum,ck_last,type_,oneex_con, coalesce(object_name_reqnum,object_name_con) object_name,coalesce(sop_name_reqnum,sop_name_con) sop_name,signdate,
					 coalesce(w.work_days,c.plan_execution_date_con) work_days, null is_concluded_in_e_shop,FIRSTNOTICESUCCESDATE,flag_16,PUBLISHDATE_REQNUM,c.is_structured_form, c.reqnum,
                      case when PURCHASENUMBER is not null and ONEEX_CON like 'Пункт 25 части 1 статьи 93%' then 1
                     else 0 end flag_demand, lotid, requestid
			from nrpz.erc_${year}_list_contract c
			left join nrpz.erc_work_days w on w.date_ = c.plan_execution_date_con
             left Join (Select distinct purchasenumber From nrpz.erc_${year}_demand Where (cnt_all=0 or cnt_adm=0) and title = 'Протокол подведения итогов определения поставщика (подрядчика, исполнителя)') d On c.reqnum=d.purchasenumber
                   
		union all	
		select null ,rejected_date, executions_date,EXECUTIONPERIOD_END, rnk, ORG_KGNTV::int4 ORG_KGNTV, penalties_party, c.org_name, price,0, price_cur, 'aaa', singlecustomer_name, object_name,placingway_name, signdate,
					coalesce(w.work_days,c.EXECUTIONPERIOD_END) work_days,is_concluded_in_e_shop,FIRSTNOTICESUCCESDATE,flag_16,PUBLISHDATE_REQNUM,c.is_structured_form, c.reqnum,
                    null,lotid::int4, requestid::int4
			from nrpz.erc_${year}_contract_kg c
			left join nrpz.erc_work_days w on w.date_ = c.EXECUTIONPERIOD_END
		) sc
join nrpz.erc_dwh_organization_kgntv dok on dok.id = sc.org_kgntv
join nrpz.erc_dwh_organization_kgntv dokgrbs on dokgrbs.id = dok.parentid
join nrpz.ERC_ORGANIZATION eo on eo.spz = dokgrbs.spz
left join nrpz.erc_${year}_contract_oneex co on co.rnk = sc.rnk
left join 
				(select p.rnk, 
						sum(p.sum_) pay_, 
						max(p.execdocdate) execdocdate
				 from 
						(select case when substring(p.rnk,1,6) = '000000' then substring(p.rnk,7) else p.rnk end rnk, p.sum_, p.execdocdate from sppr.dwh_payments p) p 
				 join 
						(select c.rnk , coalesce(w.work_days,c.plan_execution_date_con) work_days from nrpz.erc_${year}_list_contract c left join nrpz.erc_work_days w on w.date_ = c.plan_execution_date_con
							union all
							select c.rnk ,coalesce(w.work_days,c.EXECUTIONPERIOD_END) work_days from nrpz.erc_${year}_contract_kg c left join nrpz.erc_work_days w on w.date_ = c.EXECUTIONPERIOD_END
						)c on c.rnk = p.rnk
				 WHERE date_trunc ('day',p.execdocdate)<= c.work_days
				 group by p.rnk
				)pay_ on pay_.rnk = sc.rnk
where sc.rnk is not NULL;
