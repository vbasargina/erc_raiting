-- правки П7.2 и П7.4 за 1 кв. 2025, добавить lotid, requestid, is_structured_form


UPDATE nrpz.erc_${year}_contract_dirty
SET (lotid, requestid, is_structured_form) = (5596558, 5360758, 'Нет')
WHERE rnk = '2780514918025000006';

UPDATE nrpz.erc_${year}_contract_dirty
SET (lotid, requestid, is_structured_form) = (5592247,5356447, 'Нет')
WHERE rnk = '2780604059425000003';

UPDATE nrpz.erc_${year}_contract_dirty
SET (lotid, requestid, is_structured_form) = (5612176,5376376, 'Нет')
WHERE rnk = '2781402705025000125';


-- правки П7.3 за 1 кв. 2025, неправильная дата заключения контракта
UPDATE nrpz.erc_${year}_contract_dirty
SET signdate = con.contractsigndate
FROM 
(SELECT contractrnk,contractsigndate FROM nrpz.erc_dwh_contract_kgntv_${srez_number}
WHERE contractrnk IN 
('2782671807725000003',
'2782671837325000003',
'2782671831025000004',
'2782671841525000005',
'2782671841525000006',
'2780113557025000011',
'2780107502525000020',
'2780107502525000022',
'2781305472825000027',
'2781900538925000003',
'2781408901825000002',
'2781615813025000006',
'2781616528925000002',
'2780433385225000002',
'2471900855025000029',
'2784201904425000039')) con
WHERE con.contractrnk = rnk;



-- Чистим erc_${year}_contract_dirty


delete from nrpz.erc_${year}_contract_dirty where date_trunc('day', signdate)>=to_date('${date}','yyyy-mm-dd'); --конец отчетного периода
delete from nrpz.erc_${year}_contract_dirty where date_trunc('day', signdate)<to_date('${start_date}','yyyy-mm-dd'); --начало отчетного периода
delete from nrpz.erc_${year}_contract_dirty
where org_inn in ('7822002853', '7806143720', '7806143737', '7802215268', '7802215250', 
'7817044400', '7819029196', '7805283280', '7807053821', '7807053839', '7805283273', '7810293894', '7810293904', 
'7804169401', '7804169391', '7820038893', '7843000046', '7816226502', '7816226189', '7814143064', '7813188464', 
'7820038903', '7814143057', '7843000039', '7842000050', '7839000318', '7842000068', '7811139119', '7801238167',
 '7811139084', '7820073802', '7801682580', '7817106590', '7842181030', '7819042648', '7813644519', '7839127850', 
'7805765622', '7805765615', '7807241381', '7807241374', '7810795943', '7811747981', '7806573056', '7804670495', 
'7802708190', '7802708182', '7802708150', '7811747935', '7806573031', '7804670382', '7804670431', '7804670375', 
'7811747999', '7816706900', '7816706971', '7814776557', '7811747974', '7816706989', '7814776500', '7811747928', 
'7814776564', '7816706925', '7801682598', '7819029206');

Truncate Table nrpz.erc_${year}_contract_plus;
Insert into nrpz.erc_${year}_contract_plus
select * from nrpz.erc_${year}_contract_dirty;
