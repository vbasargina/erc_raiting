-- заявки

Truncate Table nrpz.erc_${year}_demand;
Insert into nrpz.erc_${year}_demand
Select  
    dem.purchasenumber,
    max ( dem.cnt_all ) cnt_all,
    max ( dem.cnt_adm ) cnt_adm,
    max(dem.max_PUBL)max_PUBL,
    min(dem.min_PUBL)min_PUBL,
    dem.flag_protocol,
    dem.title
        
From(
	Select  
		p.purchasenumber,
		p.protocolnumber,
		p.type,
            	p.title,
		count ( Distinct Case When p.type Like '%Single%' Then '1' Else d.journalnumber End) cnt_all,
		sum (Case When d.admitted Is Not Null Then 1 Else 0 End ) cnt_adm,
		max(p.max_PUBL)max_PUBL,
		min(p.min_PUBL)min_PUBL,
            max(p.max_PROTD)max_PROTD,
            Case 
                When p.type In  ('epProtocolEOK2020FirstSections','epProtocolEF2020SubmitOffers','epProtocolEZK2020Final') Then 1 
                When p.type In  ('epProtocolEOK2020SecondSections','epProtocolEF2020Final')Then 2
                When p.type In  ('epProtocolEOK2020Final') Then 3 
            Else 0 End flag_protocol
		From(
			 Select 
				p.purchasenumber,
				p.protocolnumber,
				p.type,
                p.title,
				max(p.publishdate) max_PUBL,
				min(p.publishdate) min_PUBL,
                max(p.protocoldate) max_PROTD
			 From nrpz.dwh_protocol_nrpz_acgz p
			 Where( Case When type Like 'fcs%' Then p.publishdate Else p.protocoldate End)< To_date('${date}','yyyy-mm-dd') And p.publishdate > To_date('${budget_date}', 'yyyy-mm-dd') --дата принятия бюджета спб
				And p.type In ('epProtocolEOK2020FirstSections','epProtocolEF2020SubmitOffers','epProtocolEZK2020Final','epProtocolEOK2020SecondSections','epProtocolEF2020Final','epProtocolEOK2020Final')
			 Group By p.purchasenumber, p.protocolnumber, p.type, p.title
			) p
		Left Join(
				  Select Distinct 
					purchasenumber,
					type,
					admitted,
					journalnumber,
					max(publishdate)
				  From nrpz.dwh_protocol_demand_nrpz_acgz
				  Where (purchasenumber, type,publishdate) In 
					  (Select 
							purchasenumber,
							type,
							max(publishdate)
						From nrpz.dwh_protocol_demand_nrpz_acgz
						Group By  purchasenumber, type
					  ) 
				  Group By purchasenumber, type,admitted,journalnumber
				 )d 
		  On p.type = d.type And p.purchasenumber = d.purchasenumber
		Group By p.purchasenumber, p.protocolnumber, p.type, p.title
	  )dem
Left Join (
	Select Distinct
		protocolnumber,
		purchasenumber,
        protocoldate
	From nrpz.dwh_protocol_nrpz_acgz
	Where type In ('ProtocolCancel','fcsProtocolCancel','epProtocolCancel') and protocoldate < To_date('${date}','yyyy-mm-dd')
		  ) canc On canc.protocolnumber = dem.protocolnumber And canc.purchasenumber = dem.purchasenumber And dem.max_PROTD < canc.protocoldate
Where canc.protocolnumber is null AND dem.max_PUBL<To_date('${date}','yyyy-mm-dd')
Group By dem.purchasenumber,dem.flag_protocol,dem.title;
