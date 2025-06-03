-- Контракты со среза, которые не попали раньше

Truncate Table nrpz.erc_${year}_contract_add;
Insert into nrpz.erc_${year}_contract_add
SELECT  c.contractrnk rnk,
		c.contractnumber rnk_number,
		p.pg_ikz ikz,
		c.contractsigndate signdate, 
		Null publishdate_first,
		Null publishdate_last,
		Null versionnumber_first,
		Null versionnumber_last, 
		c.contractnoticenumber notificationnumber,
		p.lotnum lotnumber, 
		coalesce(p.fordertypename,ordertypename) sop_name,
		p.oneexec singlecustomer_name,		
		c.protocoldate protocoldate,
		coalesce(c.contractsigningprice,
		Case 
			When c.contractfullprice>0 Then c.contractfullprice
			Else 0 end) PRICE,
		Case 
			When c.contractfullprice>0 Then c.contractfullprice
			Else 0 End PRICE_cur,	
		Case 
			When c.contractrejectdate Is Not Null Then 'Исполнение прекращено'
			When c.contractactualexecdate Is Not Null Then 'Исполнение завершено'
			When c.contractrnk is Null Then 'Aннулировано' 
		    Else 'Исполнение' End stage,		
		c.contractactualexecdate executions_date,
		Case 
			When date_trunc('day', c.contractrejectdate)>=to_date('${date}','yyyy-mm-dd') Then Null --конец отчетного периода
			Else c.contractrejectdate End rejected_date, 
		c.contractactualpaid rejected_paid,
		Null rejected_reason,
		p.pg_rn positionnumber,
		c.contractrejectreason rejected_reason_name,
		Case 
			When pen.id Is Not Null Then 'Пени' 
			Else Null End penalties_type,
		Case 
			When pen.id Is Not Null Then 'Поставщик' 
			Else Null End penalties_party,
		Null penalties_amount,
		c.suppliername supplier_fullname,
		c.supplierinn supplier_inn,
		c.supplierkpp supplier_kpp,
		coalesce(c.contractsubject,p.subject) object_name,
		c.customername org_name,
		c.customerinn org_inn,
		org.spz org_spz,
		c.customerid org_kgntv_contract,
		c.customerid org_kgntv_notice,
		c.grbsid,
		s.org_kgntv org_kgntv_schedule,
		c.customerid org_kgntv,
		c.price_type pricetype,
		Null joflag,
		prot.protocoldate_publ,
		prot.protocoldate_sign,
		prot_one.protocoldate_publ protocoldate_one_publ,
		prot_one.protocoldate_sign protocoldate_one_sign,
		mess.successdate firstnoticesuccesdate,
		1 flag_16,
		coalesce(cn.cnt_modif,0) cnt_modif,
		Case 
			When peva.PURCHASENUMBER Is Not Null 
			Then 1 Else 0 End flag_evasion,
         c.lotid, --правки от 30.06.23 добавить lot id
        CASE
		WHEN c.is_structured_form='f' THEN 'Нет'
		WHEN c.is_structured_form='t' THEN 'Да'
		ELSE NULL
	END AS is_structured_form, --правки от 01.10.24
		p.requestid,
		c.contractplaneexecdate executionperiod_end
	From nrpz.erc_dwh_contract_kgntv_${srez_number} c
	Inner Join nrpz.erc_dwh_procedures_kgntv_${srez_number} p On (c.lotid = p.lotuuid::int4)	
	Inner Join (Select Distinct ikz, org_kgntv  From nrpz.erc_${year}_schedule_pos)s On (s.ikz = p.pg_ikz)
	Left Join nrpz.erc_${year}_contract_plus cc On (cc.rnk = c.contractrnk)
	Left Join (Select 
					Distinct ikz 
			   From nrpz.erc_${year}_contract_plus
			   )cc_ikz On (cc_ikz.IKZ = p.pg_ikz)
	Left Join nrpz.erc_dwh_organization_kgntv org On (org.id = c.customerid)
	Left Join (Select 
					Distinct id 
			   From sppr.dwh_contract_penalty_kgntv 
			   Where reason_id in (1,3)
			   )pen On (pen.id = c.contractid)
	Left Join (Select 
					rnk,
					count(*) cnt_modif 
				From 
					(Select 
						Distinct regnum rnk,
						versionnumber,
						publishdate 
					From nrpz.dwh_contract_notice_nrpz_acgz cn 
					Where cn.name Like '%contract'
					And cn.publishdate < to_date('${date2}','yyyy-mm-dd') 
					And cn.changetype_tag is not null
					) 
			   Group By rnk
		       )cn On (cn.rnk = c.contractrnk)
	Left Join (Select 
  				    contract_rnk rnk, 
				    min(date_) successdate --изменение с successdate на date_ от 14/08/2018 Терехова
			   From nrpz.erc_${year}_contract_mess 
			   Group By contract_rnk
	           )mess On (mess.rnk = c.contractrnk)
	Left Join (Select  
					p.purchasenumber numb,
					max ( p.protocoldate) protocoldate_publ,
					max(p.SIGNDATE) protocoldate_SIGN
				From nrpz.dwh_protocol_nrpz_acgz p
				Left Join (Select 
								Distinct purchasenumber,
								PROTOCOLNUMBER, 
								max(protocoldate) protocoldate
						   From nrpz.dwh_protocol_nrpz_acgz
						   Where type In ('ProtocolCancel','fcsProtocolCancel','epProtocolCancel')
						    group by purchasenumber, protocolnumber
						   )canc On (canc.protocolnumber = p.protocolnumber And canc.purchasenumber = p.purchasenumber and canc.protocoldate>=p.protocoldate) --09.11.22 добавлено условие на дату
                 -- 'epProtocolEOK2020Final', 'epProtocolEF2020Final','epProtocolEZK2020Final','epProtocolEZK2020FinalPart' добавлены с 1ого квартала 2022
				Where  p.type in ('epProtocolEOK2020Final', 'epProtocolEF2020Final','epProtocolEZK2020Final','epProtocolEZK2020FinalPart','fcsProtocolEFSingleApp','fcsProtocolEFSinglePart','fcsProtocolEF3','epProtocolEZP1','epProtocolEZP2','epProtocolEZK1','epProtocolEOK2','ProtocolOKD5','epProtocolEOKOU3','ProtocolZKAfterProlong')  And canc.protocolnumber is Null
				Group By p.purchasenumber
				)prot on (prot.numb = c.contractnoticenumber)
	Left Join (Select  
					p.purchasenumber numb,
					max(p.protocoldate) protocoldate_publ,
					max(p.SIGNDATE) protocoldate_SIGN
				From nrpz.dwh_protocol_nrpz_acgz p
				Left Join (Select 
								Distinct purchasenumber,
								protocolnumber 
						   From nrpz.dwh_protocol_nrpz_acgz
						   Where type In ('ProtocolCancel','fcsProtocolCancel','epProtocolCancel')
						   )canc On (canc.protocolnumber = p.protocolnumber And canc.purchasenumber = p.purchasenumber)
				Where p.protocoldate < to_date('${date}','yyyy-mm-dd') 
				And p.type in ('epProtocolEOKOUSingleApp','epProtocolEOKDSingleApp','epProtocolEOKSingleApp','epProtocolEZP1','epProtocolEZP2') 
				And canc.protocolnumber Is Null
				Group By p.purchasenumber
				)prot_one on (prot_one.numb = c.contractnoticenumber)
	Left Join (Select
					Distinct p1.purchasenumber 
			   From nrpz.dwh_protocol_nrpz_acgz p1
               Left Join (select * from nrpz.dwh_protocol_nrpz_acgz 
                          where type in('fcsProtocolCancel')) p2 on p1.purchasenumber=p2.purchasenumber and p1.protocolnumber=p2.protocolnumber
			   Where p1.type in('fcsProtocolDeviation', 'fcsProtocolEvasion','epProtocolEvasion','epProtocolDeviation') 
			   And p1.protocoldate < to_date('${date}','yyyy-mm-dd') And p2.purchasenumber is null
		)peva On peva.purchasenumber = c.contractnoticenumber 
	Where 
		c.contractsigndate < to_date('${date}','yyyy-mm-dd')
		And c.contractsigndate >= to_date('${start_date}','yyyy-mm-dd') --начало отчетного периода
		AND c.CONTRACTCREATEDATE <= to_date('${date2}','yyyy-mm-dd') --01.10.24 Дата первоначального размещения документа (т.к. попадал рнк='2780113626024000023', который опубликован 11.10.24)
		And cc.rnk Is Null And cc_ikz.IKZ Is Null
		And Not regexp_like(coalesce(contractoneexecreason,'1'),	'(^Часть 1 пункт (4|5|23|42|44|46) статьи 93)') --правки от 30.06.23 убран пункт 45 
		And  customerinn Not In ('7822002853', '7806143720', '7806143737', '7802215268', '7802215250',  -- убираем избирательную комиссию
                                 '7817044400', '7819029196', '7805283280', '7807053821', '7807053839', '7805283273', '7810293894', '7810293904', 
                                 '7804169401', '7804169391', '7820038893', '7843000046', '7816226502', '7816226189', '7814143064', '7813188464', 
                                 '7820038903', '7814143057', '7843000039', '7842000050', '7839000318', '7842000068', '7811139119', '7801238167',
                                 '7811139084', '7820073802', '7801682580', '7817106590', '7842181030', '7819042648', '7813644519', '7839127850', 
                                 '7805765622', '7805765615', '7807241381', '7807241374', '7810795943', '7811747981', '7806573056', '7804670495', 
                                 '7802708190', '7802708182', '7802708150', '7811747935', '7806573031', '7804670382', '7804670431', '7804670375', 
                                 '7811747999', '7816706900', '7816706971', '7814776557', '7811747974', '7816706989', '7814776500', '7811747928', 
                                 '7814776564', '7816706925')
		and coalesce(p.oneexec,'0') not in ('Пункт 20 части 1 статьи 93 -  Закупка услуг, связанных с обеспечением визитов глав иностранных государств, глав правительств иностранных государств, руководителей международных организаций, парламентских делегаций, правительственных делегаций, делегаций иностранных государств (гостиничное, транспортное обслуживание, эксплуатация компьютерного оборудования, оргтехники, звукотехнического оборудования (в том числе для обеспечения синхронного перевода), обеспечение питания)'
								,'Пункт 20 части 1 статьи 93 Закона № 44-ФЗ -  Закупка услуг, связанных с обеспечением визитов глав иностранных государств, глав правительств иностранных государств, руководителей международных организаций, парламентских делегаций, правительственных делегаций, делегаций иностранных государств (гостиничное, транспортное обслуживание, эксплуатация компьютерного оборудования, оргтехники, звукотехнического оборудования (в том числе для обеспечения синхронного перевода), обеспечение питания)'
								,'Пункт 26 части 1 статьи 93 -  Закупка услуг, связанных с направлением работника в служебную командировку, с участием в проведении фестивалей, концертов, представлений и подобных культурных мероприятий (в том числе гастролей) на основании приглашений на посещение указанных мероприятий, а также связанных с участием в официальных физкультурных мероприятиях и спортивных мероприятиях'
								,'Пункт 26 части 1 статьи 93 Закона № 44-ФЗ -  Закупка услуг, связанных с направлением работника в служебную командировку, с участием в проведении фестивалей, концертов, представлений и подобных культурных мероприятий (в том числе гастролей) на основании приглашений на посещение указанных мероприятий, а также связанных с участием в официальных физкультурных мероприятиях и спортивных мероприятиях'
								,'Пункт 3 части 1 статьи 93 -  Закупка на выполнение работы по мобилизационной подготовке в Российской Федерации'
								,'Пункт 3 части 1 статьи 93 Закона № 44-ФЗ -  Закупка на выполнение работы по мобилизационной подготовке в Российской Федерации'
								,'Пункт 2 части 1 статьи 93 (без размещения на официальном сайте) -  Осуществление закупки товаров, работ, услуг у единственного поставщика (подрядчика, исполнителя), определенного указом или распоряжением Президента Российской Федерации, либо в случаях, установленных поручениями Президента Российской Федерации, у поставщика (подрядчика, исполнителя), определенного постановлением или распоряжением Правительства Российской Федерации. В указе или распоряжении Президента Российской Федерации установлено условие о неразмещении на официальном сайте предусмотренной настоящим Федеральным законом информации, формируемой и размещаемой при осуществлении этой закупки.'
								,'Часть 1, 2.1 статьи 15 ФЗ № 46-ФЗ -  Осуществление закупки товаров, работ, услуг для государственных и (или) муниципальных нужд у единственного поставщика (подрядчика, исполнителя), в случае, установленном Правительством Российской Федерации, в соответствии с частями 1, 2.1 статьи 15 Федерального закона от 08.03.2022 № 46-ФЗ'	
								, 'Часть 1, 2.1 статьи 15 ФЗ № 46-ФЗ -  Закупка товаров, работ, услуг для государственных и (или) муниципальных нужд у единственного поставщика (подрядчика, исполнителя), в случае, установленном Правительством Российской Федерации, в соответствии с частями 1, 2.1 статьи 15 Федерального закона от 08.03.2022 № 46-ФЗ' 
								); --18.07.23 убраны пункты непубликуемые на ЕИС
