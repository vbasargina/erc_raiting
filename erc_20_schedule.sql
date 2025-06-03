Truncate Table nrpz.erc_${year}_schedule;
Insert into nrpz.erc_${year}_schedule
Select 
	org_name,
	org_inn,
	org_spz,
	org_kgntv,
	grbsid,
	plannumber,
	versionnumber,
	publishdate
From 
	(Select 
		sh.customer_fullname org_name,
		sh.customer_inn org_inn, 
		sh.customer_regnum org_spz,
		org.id org_kgntv,
        org.parentid grbsid,
		sh.plannumber,
		sh.versionnumber,
		sh.publishdate,
		row_number() over (Partition By sh.customer_regnum, plannumber Order By sh.versionnumber::numeric Desc, sh.publishdate Desc) rn
	 From nrpz.dwh_tenderplan_20_acgz sh 
	 Inner Join nrpz.erc_dwh_organization_kgntv org On sh.customer_regnum = org.spz
	 Where sh.planyear = 20${year} And publishdate < to_date('${date}','yyyy-mm-dd') -- ограничение по дате среза и Году плана Графика
	 And org.id Not IN (10355,34455,2913,31344,2998,3020,2901,3024,2994,7817,3774,29714,2896,3015,3577,9012,3021,63486,3013,3017,7260,63865,3025,7618,2940,3011,10228, --ГУПы
				   3127,3128,3132,3133,3125,506,3129,3126,3124,3131,3134,1463,2166,2715,1536,31883, -- МВД
				   2147,1556,2398,521,  --Автономные учреждения СПБ ГАУ "ДЕТСКИЙ КИНОТЕАТР "АВАНГАРД", СПБ ГАУЗ "ГОРОДСКАЯ ПОЛИКЛИНИКА №40", СПБ ГАСУСОН "ДСО "СЕРАФИМОВСКИЙ", СПБ ГАУК "МУЗЫКАЛЬНЫЙ ТЕАТР ИМЕНИ Ф.И. ШАЛЯПИНА"
	               1610,87212, -- Федеральные МУЗЕЙ-ЗАПОВЕДНИК "ПАВЛОВСК", "ДИРЕКЦИЯ ПО ЛИКВИДАЦИИ НВОС"
				   2981,2167,3039,498, --КСП, Законодательное собрание Санкт-Петербурга, КОМИТЕТ ПО РАЗВИТИЮ ПРЕДПРИНИМАТЕЛЬСТВА И ПОТРЕБИТЕЛЬСКОГО РЫНКА САНКТ-ПЕТЕРБУРГА, Уставный суд
	               3097,1725,1030,	--Уполномочки
				   1894,3074,3081,3061,3072,3077,3060,3082,3071,3078,3086,3076,3087,3084,3063,3064,3083,3069,3073,3062,3079,3059,3066,3070,3080,3075,3068,3058,3085,3067,3065,123708,123709,123710,123711,123712,123713,123714,124301,
				   124302,124303,130406,130407,130408,130409,130410,130411,130412,130413,130414,130415,130416,130417,130418,130419,130420,130421,130422,130423,130791,130792,130793,130794,130795,130796)--Избирательные комиссии  
	)plan_ 
Where plan_.rn = 1;


-- Проверка на отстутствие унитарных и автономных предприятий 
/*SELECT * FROM erc_${year}_schedule
WHERE org_kgntv in 
(
SELECT org.id
FROM erc_dwh_organization_kgntv org
WHERE lower(org.full_name) LIKE '%унитар%'
   OR lower(org.full_name) LIKE '%автоном%'
)
;*/
