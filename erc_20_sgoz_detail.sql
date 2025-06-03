--СГОЗ
Truncate Table nrpz.erc_${year}_sgoz_detail;
Insert into nrpz.erc_${year}_sgoz_detail
SELECT s.contragent_inn,
       eo.full_name,
       eo.grbs_full_name,
       s.contragent_account,
       s.budget_type,
       s.targetexpenseitemcode, 
       s.cvr, 
       s.kosgu,
       s.sum As sgoz
FROM( 
    -- ГБУ
    SELECT s.contragent_inn, s.contragent_account, s.budget_type, s.targetexpenseitemcode, s.cvr::int2, s.kosgu::int2, s.sum, year
	FROM nrpz.erc_dwh_kf_sgoz_kgntv_${srez_number} s
	LEFT JOIN nrpz.erc_dwh_organization_kgntv o ON (s.contragent_inn=o.inn)
	WHERE s.year=20${year}
			AND o.role_code IN (3) --ГБУ
			AND s.budget_type IN ('СИЦ','СГЗ')
			AND (s.kosgu BETWEEN '221' AND '229' OR s.kosgu BETWEEN '340' AND '349' OR s.kosgu IN ('214', '310', '320', '352', '353')
			OR (s.kosgu='263' AND s.contragent_inn NOT IN ('7825357195')))
	        AND o.full_name not like '%АВТОНОМНОЕ%'
    
	UNION
    
    -- ИОГВ, ГКУ 
    SELECT s.contragent_inn, s.contragent_account, 'BUD' budget_type, s.targetexpenseitemcode, s.cvr::int2, s.kosgu::int2, s.lbo, year
	FROM nrpz.erc_dwh_lbo_kgntv_${srez_number} s
	LEFT JOIN nrpz.erc_dwh_organization_kgntv o ON (s.contragent_inn=o.inn)
	WHERE s.year=20${year}
		    AND o.role_code IN (1,8) --ИОГВ+ГКУ
			AND (((s.cvr BETWEEN '200' AND '247' )
				 OR (s.cvr = '323' AND (o.grbs_inn NOT IN ('7825675663','7840013199') OR (s.contragent_inn = '7806042256' AND s.targetexpenseitemcode = '031Я240750' AND s.kosgu = '263'))) --изменена ЦС с 01.01.2024--комитет по социальной политике + жилищный комитет
				 OR (s.cvr = '414' OR s.cvr = '412'))
				 AND s.kosgu NOT IN ('297', '298', '299', '530') --267 убрали от 01.04.25
				 AND s.contragent_account NOT IN ('0294002','0294003','0294004','0244001','0244010','0934044', '0244031')) --добавили '0934044', '0244031' от 01.04.25
			AND inn !='7802072429' --выключено от 18.04.24 стал ГБУ
) s 
JOIN 
	(SELECT DISTINCT dok.inn, dok.full_name, dok.grbs_full_name
	   FROM nrpz.erc_dwh_organization_kgntv dok 
	   JOIN nrpz.erc_dwh_organization_kgntv dokgrbs ON dokgrbs.id = dok.parentid
	   JOIN nrpz.ERC_ORGANIZATION eo ON eo.spz = dokgrbs.spz
	  WHERE dok.inn NOT IN ( '7830000426','7830001758') --выключили гуп пассажиравтотранс и водоканал 
) eo ON eo.inn=s.contragent_inn
WHERE  s.year=20${year}
and s.contragent_inn NOT IN ('7802139352','7803019724','7805016119','7811040938','7825666429') --12.05.23 
;
