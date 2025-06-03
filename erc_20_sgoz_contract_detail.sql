--Используется для расчета заменателя 
--Детализация контракты,заключенные до отчетного периода

Truncate Table nrpz.erc_${year}_sgoz_contract_detail;
Insert into nrpz.erc_${year}_sgoz_contract_detail
Select fin.customerinn,
	   fin.customername,
	   fin.grbsname,
	   fin.LOTID,
	   fin.CONTRACTSIGNINGPRICE,
	   fin.CONTRACTREJECTDATE,
       fin.contractrnk,
       fin.contractsigndate, 
       fin.pg_ikz,
       fin.pg_rn,
       fin.finsum,
       fin.finsum_f, 
       fin.targetexpenseitemcode, 
       fin.cvr, 
       fin.kosgu,
       CASE WHEN date_trunc('day',CONTRACTREJECTDATE)>=to_date('${date}','YYYY-MM-DD') THEN finsum
                        WHEN CONTRACTREJECTDATE is NOT NULL THEN finsum_f ELSE finsum end fin_before
From
      (
         select distinct dok.id, dok.inn
         from nrpz.erc_dwh_organization_kgntv dok
         join nrpz.erc_dwh_organization_kgntv dokgrbs	on dokgrbs.id = dok.parentid
         join nrpz.ERC_ORGANIZATION eo	on eo.spz = dokgrbs.spz
		 join (select distinct contragent_inn inn from nrpz.erc_${year}_sgoz_detail) sch on sch.inn = dok.inn
         where dok.inn not in ( '7830000426','7830001758') --выключили гуп пассажиравтотранс и водоканал 
		and dok.inn NOT IN ('7802139352','7803019724','7805016119','7811040938','7825666429') --12.05.23 стали автономными учр.
       ) org
left join 
       (
    	select 
            con.customerinn,
            con.customername,
            con.grbsname,
            con.LOTID,
            con.CONTRACTSIGNINGPRICE,
            con.CONTRACTREJECTDATE,
            con.contractrnk,
            con.contractsigndate, 
            pro.pg_ikz,
            pro.pg_rn,
            tar.finsum,
            tar.finsum_f,
            tar.targetexpenseitemcode,
            tar.cvr,
            tar.kosgu
        FROM (SELECT * FROM
                (Select 
                       LOT_ID, targetexpenseitemcode, cvr, kosgu,
                       sum(finsum) AS finsum, sum(finsum_f) AS finsum_f
                from (--ГБУ
                      SELECT fin.LOT_ID, fin.targetexpenseitemcode, fin.expensetypecode cvr, coalesce(fin.kosgucode,lsr.kosgu) kosgu,
                             case when fin.type=1 then fin.FINSUM end finsum,
                             case when fin.type=2 then fin.FINSUM end finsum_f
                      FROM (SELECT CONTRACT,LOT_ID,FINSUM,BSUM,OBSUM, MONTH, YEAR,SUPPLIER_ID,DOC_NAME,DOC_NUMBER,DOC_DATE,TYPE,PRODUCT,ECONOMICCODE,TARGETEXPENSEITEMCODE,EXPENSESNUMERATION,SUBSECTION,EXPENSETYPECODE,EXPENSETYPENAME,FUND_CODE,GRBS_CODE,KOSGUCODE,KOSGUTITLE,DESCRIPTION,EXP_ACCOUNT,BUDGET_TYPE,FINSOURCE,YEAR_ACCEPT,BUDGET_ID,SUPPLIER_INN,STAGE_ID,PUBLISHED,IMPROPER_EXECUTION_TEXT,FULFILMENT_SUM_RUR,DELIVERY_ACCEPT_DATE,IS_DONE,CUSTOMER_INN,PAY_DOC_NAME,EIS_DATE,DOC_TYPE,max(AIP_CODE) AIP_CODE,max(AIP_NAME) AIP_NAME,sum(FULFILMENT_SUM) FULFILMENT_SUM ,INN,REQ_CODE
		              		FROM nrpz.ERC_DWH_CONTRACT_FIN_KG_${srez_number}_f1
		              		WHERE YEAR = 20${year} 
		                    GROUP BY CONTRACT,LOT_ID,FINSUM,BSUM,OBSUM,MONTH,YEAR,SUPPLIER_ID,DOC_NAME,DOC_NUMBER,DOC_DATE,TYPE,PRODUCT,ECONOMICCODE,TARGETEXPENSEITEMCODE,EXPENSESNUMERATION,SUBSECTION,EXPENSETYPECODE,EXPENSETYPENAME,FUND_CODE,GRBS_CODE,KOSGUCODE,KOSGUTITLE,DESCRIPTION,EXP_ACCOUNT,BUDGET_TYPE,FINSOURCE,YEAR_ACCEPT,BUDGET_ID,SUPPLIER_INN,STAGE_ID,PUBLISHED,IMPROPER_EXECUTION_TEXT,FULFILMENT_SUM_RUR,DELIVERY_ACCEPT_DATE,IS_DONE,CUSTOMER_INN,PAY_DOC_NAME,EIS_DATE,DOC_TYPE,INN,REQ_CODE
                      		) fin
                      Join nrpz.ERC_DWH_CONTRACT_KGNTV_${srez_number}_f1  сont on сont.contractid=fin.contract
                      Join nrpz.erc_dwh_organization_kgntv org On org.inn=сont.customerinn
                      Left Join sppr.dwh_kf_lsr lsr On lsr.exp_code=fin.expensesnumeration
                      WHERE fin.budget_type IN ('СИЦ','СГЗ')
                        AND fin.YEAR = 20${year} -- 01.04.25 имеется финансирование на текущий финансовый год
                        AND org.role_code IN (10,3) --роль автономных и бюджетных учреждений
                        AND (coalesce(fin.kosgucode::int2,lsr.kosgu::int2) BETWEEN 221 AND 229
                        	 OR coalesce(fin.kosgucode::int2,lsr.kosgu::int2) BETWEEN 340 AND 349
                        	 OR coalesce(fin.kosgucode::int2,lsr.kosgu::int2) IN (214, 263, 310, 320, 352, 353))
                      
                      union all
                      
                      -- ИОГВ и ГКУ
                      SELECT fin.LOT_ID, fin.targetexpenseitemcode,fin.expensetypecode cvr,coalesce(fin.kosgucode,lsr.kosgu) kosgu,
                             case when fin.type=1 then fin.FINSUM end finsum,
                             case when fin.type=2 then fin.FINSUM end finsum_f
                      FROM (SELECT CONTRACT,LOT_ID,FINSUM,BSUM,OBSUM, MONTH, YEAR,SUPPLIER_ID,DOC_NAME,DOC_NUMBER,DOC_DATE,TYPE,PRODUCT,ECONOMICCODE,TARGETEXPENSEITEMCODE,EXPENSESNUMERATION,SUBSECTION,EXPENSETYPECODE,EXPENSETYPENAME,FUND_CODE,GRBS_CODE,KOSGUCODE,KOSGUTITLE,DESCRIPTION,EXP_ACCOUNT,BUDGET_TYPE,FINSOURCE,YEAR_ACCEPT,BUDGET_ID,SUPPLIER_INN,STAGE_ID,PUBLISHED,IMPROPER_EXECUTION_TEXT,FULFILMENT_SUM_RUR,DELIVERY_ACCEPT_DATE,IS_DONE,CUSTOMER_INN,PAY_DOC_NAME,EIS_DATE,DOC_TYPE,max(AIP_CODE) AIP_CODE,max(AIP_NAME) AIP_NAME,sum(FULFILMENT_SUM) FULFILMENT_SUM ,INN,REQ_CODE
		              		FROM nrpz.ERC_DWH_CONTRACT_FIN_KG_${srez_number}_f1
		              		WHERE YEAR = 20${year}
		                    GROUP BY CONTRACT,LOT_ID,FINSUM,BSUM,OBSUM,MONTH,YEAR,SUPPLIER_ID,DOC_NAME,DOC_NUMBER,DOC_DATE,TYPE,PRODUCT,ECONOMICCODE,TARGETEXPENSEITEMCODE,EXPENSESNUMERATION,SUBSECTION,EXPENSETYPECODE,EXPENSETYPENAME,FUND_CODE,GRBS_CODE,KOSGUCODE,KOSGUTITLE,DESCRIPTION,EXP_ACCOUNT,BUDGET_TYPE,FINSOURCE,YEAR_ACCEPT,BUDGET_ID,SUPPLIER_INN,STAGE_ID,PUBLISHED,IMPROPER_EXECUTION_TEXT,FULFILMENT_SUM_RUR,DELIVERY_ACCEPT_DATE,IS_DONE,CUSTOMER_INN,PAY_DOC_NAME,EIS_DATE,DOC_TYPE,INN,REQ_CODE
                      		) fin
                      Join nrpz.ERC_DWH_CONTRACT_KGNTV_${srez_number}_f1  сont on сont.contractid=fin.contract and сont.customerinn=fin.customer_inn
                      Join nrpz.erc_dwh_organization_kgntv org On org.inn=сont.customerinn
                      Left Join sppr.dwh_kf_lsr lsr On lsr.exp_code=fin.expensesnumeration
                      WHERE fin.budget_type NOT IN ('ОСИЦ','ОСГЗ') 
                      	AND fin.YEAR = 20${year} -- 01.04.25 имеется финансирование на текущий финансовый год
	                    AND org.role_code IN (1,8) --ИОГВ+ГКУ
	                    AND (((fin.expensetypecode BETWEEN '200' AND '247' ) 
	                      	OR (fin.expensetypecode = '323' AND (org.grbs_inn NOT IN ('7825675663') OR (fin.inn = '7806042256' AND fin.targetexpenseitemcode = '031Я240750' AND fin.economiccode = '263'))) --изменения ЦС от 01.01.24 комитет по социальной политике 
	                      	OR (fin.expensetypecode ='414' OR fin.expensetypecode = '412')) 
	                      	AND coalesce(fin.kosgucode,lsr.kosgu) NOT IN ('297','298','299','530') -- 267 убираем от 01.04.25
	                      	AND org.contragent_account NOT IN ('0294002','0294003','0294004','0244001', '0244010','0934044', '0244031')) -- '0934044', '0244031' от 01.04.25
                      ) 
                  GROUP BY LOT_ID,targetexpenseitemcode,cvr,kosgu
                 )   
               where finsum is not null  --имеется финансирование на текущий финансовый год
              ) tar
      	  join  nrpz.ERC_DWH_CONTRACT_KGNTV_${srez_number}_f1 con ON con.LOTID = tar.LOT_ID 
      													and stagetitle <> 'Контракт недействителен'       													
      	  left join ( Select lotuuid, pg_rn, pg_ikz, Count(*) 
      			  	  From nrpz.ERC_DWH_PROCEDURES_KGNTV_${srez_number}
      			  	  Group by lotuuid,pg_rn, pg_ikz
                	) pro on con.LOTID = pro.LOTUUID
          WHERE con.contractsigndate<to_date('${start_date}','yyyy-mm-dd') -- 01.04.25 контракт заключен до начала текущего финансового года
          OR (pro.pg_rn NOT like '20${year}%' AND con.contractsigndate<to_date('${date}','yyyy-mm-dd'))   --контракт заключен от ПГ не текущего года, но в данном отчетном периоде	
      	 ) fin On org.inn=fin.customerinn
where fin.contractrnk is not null;
