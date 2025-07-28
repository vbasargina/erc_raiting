-- Числитель
-- Детализация контракты по принятым обязательствам

Truncate Table nrpz.erc_${year}_sgoz_contract_detail_v1;
Insert into nrpz.erc_${year}_sgoz_contract_detail_v1
WITH fact as (
SELECT lot_id, contractrnk, YEAR, targetexpenseitemcode,budget_type,expensetypecode, kosgucode,fund_code,req_code,AIP_CODE, subsection,
sum(finsum) finsum_f
FROM nrpz.erc_dwh_con_payments_kg_${srez_number}
WHERE YEAR = 2025
GROUP BY lot_id, contractrnk, YEAR, targetexpenseitemcode,budget_type,expensetypecode, kosgucode,fund_code,req_code,AIP_CODE, subsection
)
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
       fin.finsum_f, fin.targetexpenseitemcode, fin.cvr, fin.kosgu,
       finsum fin_now
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
            con.customerinn,con.customername,con.grbsname,con.LOTID,con.CONTRACTSIGNINGPRICE,con.CONTRACTREJECTDATE,
            con.contractrnk,con.contractsigndate, pro.pg_ikz,pro.pg_rn,
            tar.finsum,
            tar.finsum_f,
            tar.targetexpenseitemcode,
            tar.cvr,
            tar.kosgu
        FROM ( SELECT * from
                (Select 
                       LOT_ID, targetexpenseitemcode, cvr, kosgu,
                       sum(finsum) AS finsum, sum(finsum_f) AS finsum_f
                from (--ГБУ
                      SELECT fin.LOT_ID, fin.targetexpenseitemcode, fin.cvr, coalesce(fin.kosgucode,lsr.kosgu) kosgu,
                             fin.sumi finsum,
                             fact.finsum_f
                      FROM nrpz.erc_dwh_kf_con_payment_${srez_number} fin
                      Join nrpz.erc_dwh_con1_kgntv_${srez_number}  сont on сont.lotid=fin.lot_id
                      Join nrpz.erc_dwh_organization_kgntv org On org.inn=сont.customerinn
                      Left Join sppr.dwh_kf_lsr lsr On lsr.exp_code=fin.cvr
                      LEFT JOIN fact ON fact.lot_id = fin.lot_id AND fact.year = fin.year 
                      AND fact.targetexpenseitemcode = fin.targetexpenseitemcode 
                      AND fact.budget_type = fin.budget_type AND fact.expensetypecode = fin.cvr
                      AND fact.kosgucode = fin.kosgucode AND COALESCE(fact.aip_code, '0') = COALESCE(fin.aip_code, '0') 
                      AND fact.subsection = fin.subsection AND COALESCE(fact.fund_code, '0') = COALESCE(fin.fund_code, '0')
                      AND COALESCE(fact.req_code, '0') = COALESCE(fin.req_code, '0')                      
                      WHERE fin.budget_type IN ('СИЦ','СГЗ')
                        AND fin.YEAR = 20${year} -- 01.04.25 имеется финансирование на текущий финансовый год
                        AND org.role_code IN (10,3) --роль автономных и бюджетных учреждений
                        AND (coalesce(fin.kosgucode::int2,lsr.kosgu::int2) BETWEEN 221 AND 229
                        	 OR coalesce(fin.kosgucode::int2,lsr.kosgu::int2) BETWEEN 340 AND 349
                        	 OR coalesce(fin.kosgucode::int2,lsr.kosgu::int2) IN (214, 263, 310, 320, 352, 353))
                      
                      union all
                      
                      -- ИОГВ и ГКУ
                      SELECT fin.LOT_ID, fin.targetexpenseitemcode,fin.cvr,coalesce(fin.kosgucode,lsr.kosgu) kosgu,
                             fin.sumi finsum,
                             fact.finsum_f
                      FROM nrpz.erc_dwh_kf_con_payment_${srez_number} fin
                      Join nrpz.erc_dwh_con1_kgntv_${srez_number}  сont on сont.lotid=fin.lot_id and сont.customerinn=fin.customerinn
                      Join nrpz.erc_dwh_organization_kgntv org On org.inn=сont.customerinn
                      Left Join sppr.dwh_kf_lsr lsr On lsr.exp_code=fin.cvr
                      LEFT JOIN fact ON fact.lot_id = fin.lot_id AND fact.year = fin.year 
                      AND fact.targetexpenseitemcode = fin.targetexpenseitemcode 
                      AND fact.budget_type = fin.budget_type AND fact.expensetypecode = fin.cvr
                      AND fact.kosgucode = fin.rs AND COALESCE(fact.aip_code, '0') = COALESCE(fin.aip_code, '0')
                      AND fact.subsection = fin.subsection AND COALESCE(fact.fund_code, '0') = COALESCE(fin.fund_code, '0') 
                      AND COALESCE(fact.req_code, '0') = COALESCE(fin.req_code, '0')
                      WHERE fin.budget_type IN ('BUD')  
                      	AND fin.YEAR = 20${year} -- 01.04.25 имеется финансирование на текущий финансовый год
	                    AND org.role_code IN (1,8) --ИОГВ+ГКУ
	                    AND (((fin.cvr BETWEEN '200' AND '247' ) 
	                      	OR (fin.cvr = '323' AND (org.grbs_inn NOT IN ('7825675663') OR (fin.customerinn = '7806042256' AND fin.targetexpenseitemcode = '031Я240750' AND coalesce(fin.kosgucode,lsr.kosgu) = '263'))) --изменения ЦС от 01.01.24 комитет по социальной политике 
	                      	OR (fin.cvr ='414' OR fin.cvr = '412')) 
	                      	AND coalesce(fin.kosgucode,lsr.kosgu) NOT IN ('297','298','299','530') -- 267 убираем от 01.04.25
	                      	AND org.contragent_account NOT IN ('0294002','0294003','0294004','0244001', '0244010','0934044', '0244031')) -- '0934044', '0244031' от 01.04.25
                      )
                      GROUP BY LOT_ID,targetexpenseitemcode,cvr,kosgu
                      )   
                where finsum is not null    
              ) tar
      	  join  nrpz.erc_dwh_con1_kgntv_${srez_number}  con ON con.LOTID = tar.LOT_ID 
      													and stagetitle <> 'Контракт недействителен' 
      													and con.contractsigndate<to_date('${date}','YYYY-MM-DD')
      													AND con.contractsigndate>=to_date('${start_date}','yyyy-mm-dd') -- 01.04.25 контракт заключен в отчетном периоде по плану-графику текущего финансового года

      	  left join (   
                    Select lotuuid,pg_ikz,pg_rn, delegated, Count(*)
                    From nrpz.ERC_DWH_PROCEDURES_KGNTV_${srez_number}
                    Group by lotuuid,pg_ikz,pg_rn, delegated
                	) pro on con.LOTID = pro.LOTUUID
      	  where pro.pg_rn like '20${year}%' AND delegated != 1 -- убираем переданные полномочия
      ) fin On org.inn=fin.customerinn
where fin.contractrnk is not NULL;
