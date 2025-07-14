-- Детализация по малым закупкам
truncate table nrpz.erc_${year}_data_em_purchase;
insert into nrpz.erc_${year}_data_em_purchase
select 	o.grbs_full_name,
		o.parentid as grbsid,
		k.org_kgntv,
		k.org_name,
		k.org_inn,
		k.rnk,k.signdate,
		k.EXECUTIONPERIOD_END,
		k.REJECTED_DATE,
		k.EXECUTIONS_DATE,
		k.PENALTIES_TYPE,
		k.F_productprice,
		k.price,
		k.price_cur,
		case when k.is_concluded_in_e_shop is not null or singlecustomer_name like('%пунктами 4 и 5%') then 1 else null end bra1,
		1 bra2,
		k.OBJECT_NAME,
		k.PLACINGWAY_NAME,
		k.SINGLECUSTOMER_NAME,
		k.lotid,
		k.requestid,
        c.supplierinn,
        c.supplierkpp, 
        c.suppliername,
        coalesce(e.fact_address_text, c.SUPPLIERADDRESS_FACT) fact_address_text, 
        coalesce(e.address_text,c.SUPPLIERADRESS) address_text,
        case when k.rnk like '%E%' or singlecustomer_name like('%пунктами 4 и 5%') then (
        case when length(coalesce(supplierinn,'0')) = 10 and substring(supplierkpp,1,2) = '78' then 'Да'
             when length(coalesce(supplierinn,'0')) = 10 and substring(supplierkpp,1,2) <> '78' then 'Нет'
             when length(coalesce(supplierinn,'0')) <> 10  and substring(coalesce(e.fact_address_text, c.SUPPLIERADDRESS_FACT),1,2) = '19' then 'Да'
        else 'Нет' end) else null end mest_post 
from nrpz.erc_${year}_contract_kg k
join nrpz.erc_dwh_organization_kgntv o on o.id=k.org_kgntv::int4
left join (select register_number,max(fact_address_text) fact_address_text,max(address_text) address_text from sppr.eshop_contract where contract_id <> 685655 group by register_number) e on e.register_number = k.rnk
left join nrpz.erc_dwh_contract_kgntv_${srez_number} c on c.REQUESTID = k.REQUESTID::integer
where (singlecustomer_name like('%пункт 4%')or singlecustomer_name like('%пункт 5%')or singlecustomer_name like('%пунктами 4 и 5%') or singlecustomer_name like('%Часть 12 статьи 93 Закона № 44-ФЗ%'));


delete from nrpz.erc_${year}_data_em_purchase
where org_kgntv::int4 in (2167,498,1725,3064,2981,1030,3097);
