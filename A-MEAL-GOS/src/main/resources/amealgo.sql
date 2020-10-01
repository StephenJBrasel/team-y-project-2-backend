
drop table if exists amg_votes; 
drop table if exists amg_meal_users; 
drop table if exists amg_meal_restaurants; 
drop table if exists amg_likes; 
drop table if exists amg_meals; 
drop table if exists amg_restaurants;
drop table if exists amg_users;
DROP TABLE IF EXISTS amg_winning_vote;

create table amg_users( 
	amg_user_id						serial not null, 
	username 						varchar(255) not null,  -- username is not unique so that users can rename themselves / users can eeach have the same name, e.g., Daniel 
	password_hash					bytea not null, -- password is hashed for security with CSPRNG algorithm in java 
	password_salt					bytea not null, -- password is salted prior to hashing for increased security 
	email							varchar(255) unique not null,
	role                            varchar(255),
	constraint user_id_pk 
		primary key(amg_user_id) 
); 

-- all the restaurants that were the final choice from any given meal, used for history 
-- may not be used 
create table amg_restaurants( 
	amg_restaurant_id				serial not null, 
	place_id 						text, -- the Google Maps id for a specific place 
	restaurant_name					text, -- the name of the restaurant 
	address						    text, -- the address of the restaurant
	constraint amg_restaurant_id_pk 
		primary key(amg_restaurant_id) 
);
 
-- 
create table amg_meals( 
	amg_meal_id						serial not null, 
	num_votes 						int default 3, -- determines how many votes each user gets during the voting period 
	meal_name						varchar(255) not null, -- user defined name for the meal 
	final_restaurant_id				text, -- the id of the most recent round of voting's restaurant finalist. 
	-- invite_code						varchar(255) unique not null, 
	constraint meal_id_pk 
		primary key(amg_meal_id), 
); 

-- used to get previously enjoyed restaurants. 
create table amg_likes( 
	amg_restaurant_id				int not null, -- the Google Maps id for a specific place 
	amg_user_id 					int not null, 
	constraint amg_like_id_pk 
		primary key(amg_restaurant_id, amg_user_id), 
	constraint like_restaurant_fk 
		foreign key (amg_restaurant_id) 
		references amg_restaurants (amg_restaurant_id), 
	constraint like_user_fk 
		foreign key (amg_user_id) 
		references amg_users (amg_user_id) 
); 

-- all the restaurants being chosen from any given meal 
create table amg_meal_restaurants( 
	amg_restaurant_id					int not null unique, 
	amg_meal_id 						int not null, 
	constraint amg_meal_restaurant_id_pk 
		primary key(amg_restaurant_id, amg_meal_id), 
	constraint restaurant_fk 
		foreign key(amg_restaurant_id) 
		references amg_restaurants (amg_restaurant_id), 
	constraint meal_fk 
		foreign key(amg_meal_id) 
		references amg_meals (amg_meal_id) 
); 

-- Junction table of users and meals: shows which meals have which users. 
create table amg_meal_users( 
	amg_meal_id							int not null, 
	amg_user_id							int not null unique, 
	constraint meal_users_pk 
		primary key(amg_meal_id, amg_user_id), 
	constraint meal_fk 
		foreign key (amg_meal_id) 
		references amg_meals (amg_meal_id), 
	constraint users_fk 
		foreign key (amg_user_id) 
		references amg_users (amg_user_id) 
); 

-- used in the meal to vote on which restaurant to go to 
create table amg_votes( 
	amg_vote_id						serial not null, 
	restaurant_id					int, -- the restaurant being voted for 
	vote_meal_id					int, -- the meal that this vote was in 
	amg_user_id						int, -- the voter id 
	amg_vote						smallint default 0, -- negative = no, 0 = skip, positive = yes 
	constraint amg_vote_id_pk 
		primary key(amg_vote_id), 
	constraint vote_restaurant_fk 
		foreign key (restaurant_id) 
		references amg_restaurants (amg_restaurant_id), 
	constraint vote_meal_fk 
		foreign key (vote_meal_id) 
		references amg_meals (amg_meal_id), 
	constraint vote_user_fk 
		foreign key (amg_user_id) 
		references amg_users (amg_user_id) 
); 

-- +-------------------------------------------------------------+ 
-- +                    	  TEST DATA 
-- +-------------------------------------------------------------+ 
delete from amg_votes; 
delete from amg_meal_users; 
delete from amg_meal_restaurants; 
delete from amg_likes; 
delete from amg_meals; 
delete from amg_restaurants;
delete from amg_users;

-- password is password.
insert into amg_users (email, password_hash, password_salt, role, username) 
values 
	('aanderson@revature.com',decode('CC6ADC014D2C12A7768A800F4B681C8C','hex'),decode('6C8EE809054647C024EB800B3494940B115B264FBEA01251DFC1D7B004937DA820F1F099C11AE834BF47027F1C4A34957F4202592BAC2BEA5CC512871808F8E0A4DCA227CE1E3313977DD147EDA8CCD96BB15E91C036941D2E0C0BDFAC26829BE956D12CE2D30B295DB0C4BA91B9B88C889996FCB174438DC68DBDB8E315473EC235542A388C8B54C0D35E45DC68B97D0289B8B7622DBB184E51BBBDF5AEEFBF8C63893CD0E5025B139F46D09A70524F5C0A4BAF0DC8AA2B0E70CFE3A33D20287D65F6328E31D38D528F069FFAF448FCF3120B3696E0AB6C9CB9319F0484D1F89BAFBBD3ACF26B4A17D142D13642D965B79489402213203688813973591B2DC7','hex'),'ADMIN','aanderson'),
	('bbarker@revature.com',decode('E18B866F69C7F0CD5EABA7ECA56DAE25','hex'),decode('9A20642098F9DEC65C556900A64B03B0394E7964058C881A7C8E045A5044D597E4AA542782632AB51A465323EC23BDE4014059C9B9193C362D8E2F3259F320053E2C6BB2937ABA0429540E9F38CF17666C24A7578993C6CBE58B956B55F96B73FD981AF9FD63E39B8AE4367729239D7AFF92FB01E930554CBEEB99ADEE762D0C0781092080C72C554AFA37E33C2ADB1D188DF6029A0D9EBF8E9EAEF7464AD9D5BA1FFC11D796D4C471DE02C404801DA18749D8392B740173201D32A44506469D7E710757CFC90B6932C18AE6960599D55512F4C1079B3D68F69CE85EA5378039155A1B9D2840CCDF13359B1AE3CE90138BE2E9493353BE18CE6DE0DACB66903E','hex'),'MANAGER','bbarker'),
	('ccourtson@revature.com',decode('12555E03C4A0245334132614229CFC3A','hex'),decode('0FED90EEA3D99B857B56409B52BB9079437349B1CF8D1311DE009BB1D4816BCCD94074CF4E89678538FE9797F4EB44A077E0A6BFCEDE9885CBC57207B22C2952C19887F6645259289D5965FC2E360CB051F8A8FCE7940DAC0ADBCC570124FDB244C4CF5A7357CD75B1383887702AEC968C0D6A93D7AE2AAB5079DD45CE804A22AC9C88BD55F273512C8D3A549A724B191553D4595205AE3D898B75A9BB693F6A30B2C690E97D67C74C47E211CECDDB3597218F006B2CA6D0CC61F6F2D900F2126EDF5BAC208610EBFF86240696370DBC6E47CDE1C3D62021406FF55B5F49C74EC68CD90A4DB15C60169D6B8074B78C06FAF41468B2080D13DADB6AC0E63C31EE','hex'),'BASIC_USER','ccourtson'),
	('ddangerous@revature.com',decode('292728118F6DFD72732E9B3A08CCACCB','hex'),decode('E60EE6E10FBC5E1211347472BCB13C51336266415D5CF62A8AFE30AAE37FBFBC03ED8743B6D22FC594EF49E64FD0266E5002785AE9EDD16FBB2F76AA2BB4F6EC998F7360B6C8B77A98CF185EF1D432443240D9B633D7FD94CA449B9C635C1DF03C25082E2E415E64A0D8291E23A32365F2ECA47CEED33A9D6F97058AEBCE4FA5A9ABCEF51DB5165284671B2F95E7B9986B3DCE73BEF77D623161310639CC05F8308834976614F344B79733946DCE8A6F97F426E182FF0DA082D9CD1F88B837EFEE9D093865AEB78AB3269B7FD798E6DB8A6B97ADE525137565D7478D8F0ACB586E4A8E911B71C8308DE6BF84C66E1E2D3613805CD3824B3B850B3839E3BE540D','hex'),'LOCKED','ddangerous'),
	('eelite@revature.com',decode('B4EBB78A7AF2D0391227C1EDF45EF979','hex'),decode('7A70DDEBE2EF08E1635C9A1A1309FE135AB12526E52D6D2A013E290289131C18D98E443803386A4E7A816A4EA1FE3BE8EC54EC7E4C47FA8284D0EB7DA552CF1BAB098126DC226168D0B1F47D6B61A2213512BD8EF15C37956269921EEAC1CA6CB68B2E835CFB316368C21CBDF6724498DF9527FA4E0DF2236838AB051861A83870380C3DE4FAA0C8F2B8E7E2A92D7E40605FCBE9A3C8E29F4CD28869E226C09F687E9A7C4CC11EEA63FAC61FED0ABD60951788FEBB941D8C9FAA87D65708E973E5AFB22F01A622B61C401FCDD4FDCEAC98FE97E5A50A7E1D1E1CFD464504A34AC38B3EAAB8288989A9B97C9DFCEB491D4BDECAA9D07DDD0DDEEAE9A9DDDE9385','hex'),'BASIC_USER','eelite'),
	('ffreeman@revature.com',decode('792A2DF4424068BFEC5B494242186636','hex'),decode('D060D7071947682847333D9BFCB71A62E1C2C7554032F5734632B7278A1D33CCC203ACC1B790547451A2529299A8A085F31C6FB53768BC4553EAD90F3D25B5749F0E5B719879301E97CF8A79E698C577D77346D47040B04AF9D687C83AA6FF0BABB59D77680CFFB8BB68468641628DF4BD768672444308BF34894374620051E3BCB4F656555813C98E0A65C4A78334E73AC1B224C580F71789FE072B655D61044C9B19530A2DA4CBDDEDC1DCCEC9050A7DAF3B53D98AC277C745609BC384CC2F5BEE4D1212510B6DF57391A04626E93EBA0F373C90B5A0D71BCD68E5463CB97FE19F5E0FD45AFB47AB4E1A24E425388F55F11FC32B618FB5D536C2ABBD5C3F43','hex'),'BASIC_USER','ffreeman'),
	('ggordon@revature.com',decode('B25FF152F7DFC8CE2534230ACB4A79BB','hex'),decode('989DEE5F4DB4FD8B6990CBA08499BAA2580D1C8DA0CDB5E46BB684401967867BCE4EC3716ADB219F2132239AF43252A66AA12526B8B20F40A4340742DE7F59D9DACA7E9B16B51196E17C82E751EFA3CA2157E346E7A0664B287229DEE6E4391AF4FE61AD6FAC76EF4B87C338A526601DF2A71E5F8C02D585A707EBB39955E66A855E4E1705594EFA1BCF08BF577B623AFABAA6B6D2B3B20CBCEB88558525E8179A712CB97D7648B523959CB1250725820CDA0A752807293E53A9FFDB3FA65FBA23B8F1F2DF82299CDDA66018D32B3763C7B01D201071FCF889A4F54B3995D6AB8522ADB3C52452EF13D225AE5E3A6E6D55D4B748C4026FC465B04B08520894B4','hex'),'BASIC_USER','ggordon'),
	('hharrison@revature.com',decode('1BB3916232E3D8F74333BC01A11FD782','hex'),decode('67A5B7E2E8B94CF55C863C2F49CA516DE390763B7B1CE085C24A22C9D652724DBEF69EA31A13C6C3B35F50126D950A19C8A674BDF2CA8207A65A05A1B2D835D3CF9D2AAD320E4CEC4625F850C521606188A94AAEB8DA92F7E4A9F0A51E63666D37D2CBCAF2D8C12BA1B8F1B2266C051A5CCC2EA88E5E5E1626116F725774426276F978E7095BDD5775CCC56C92EA64E131E3EBD7364F628E4C57C2C0B90D841C5FAF4382636D6F1A1975418188BE56E4AE976E58F9423A453BAA18268F0B9F7546DB1F4ED6514625EC5C43DD07A678839462F5CF2EFE629E9D920F56D649A107AA7672EB0791D211A3CD2A448C0C0BA99458C55139127AE0F37EDBF729E6BDDE','hex'),'BASIC_USER','hharrison'),
	('iirwin@revature.com',decode('967C6C8C560D2803BB7D8CE34ECADAD9','hex'),decode('DEE37420903B79789C899544D423FDA307F2C7E85DD83DE86B89B88A8C877F0DC7FB4355ED31559357B4384AF6F19E78F68EF8554137C23FA1149904D5BF146E1392477E6E8EE37B4F7B51317F1299A55A300291B4C68F277C468483DDEF17D3F9C241AC6DE52DE23262B946ADCAA9DCD6E12DEE97DBDE86537118E9104D61C7DD11D0D211C16E02E22A71C110431E467C7DDD40C5963D7064229D3DE6C94542695B9373C7C3EE72197B90E312CFF8A008C2CD79E0822E94DACE6EF454CB6214C04AD58FC506674693E6E4996235892B9E469AB68EB0732508E1025FE1E5B39F1AD54E991CFA486CF90C5050D7DF3DEF54EFCB475A16C765B8E1B6110B991D02','hex'),'BASIC_USER','iirwin'),
	('jjackson@revature.com',decode('FAF66244321E8593B5EB5072D4521374','hex'),decode('33D4D30F2FE1D87DFBCE5A7B9BECFB2E6C064DE47DC84E0325CEB1EEBCD79DB42B53401746B2B2C88833CB0BF3E9A8B7036E69D89438B84874CAF9CFABA34C021142996D251247BA9F94582CD27DAC52B3A613CD9E2FD8292A07FB9EEC9AEFCCD807A53682F025FE9CA951EDA3D7D1C92F5BC17724963E8F77AD28B12E2574572B1358BD5CA7FD3B93B140B98DE45FCF9A7123C2E09AEA20978FC9A5F903A6682CF4DB429D9C8780B26CAA8EF8FD6936E84A1E99C87AFA72CCD0346F763120B287975B7DDB30E1F325CF9F3F11CFAC5958F3CCE9539DDF7C62B9C8CC742C55940590308F3CA4A97529AC72116C12B835DDA5FEA7AFAED9DC58A22569FB173B81','hex'),'BASIC_USER','jjackson'),
	('kkirk@revature.com',decode('2A694371D23E2FE95BC417E9B6DC2EF7','hex'),decode('3FE60407880E8078213B1562A0D2EE53A2520B0FA163990B44F98382FAE1F789F1787FDB66BB56995F91AD9F135FC0AF8B8B4A90222D5A7C9659D160812BE15DB9711E5D06C1832D18EE0C308B1E31988DF3EB59F4436BC3C59C957C15D4CA34FE188144B6520D3051A2F2A042BCD408A8AB0B1566BD59752F8AA0CBB5FC736B24B9402BDD5570D53B4295663158235D0A56650E6B1DD1D1D5C54FF932176F67807D333298C45B52BE084AA2CADAE70BD6A03BCF0CDF9862BBCB3C7E6B9E46453EE4A4522C3D38746855DF8E64C1D23C43691E0FAACF9D922A3F1AD0ABC1CB2E1DCD72D7257CD58A913B6AFB569D50053F0CD7909C1252E338C4A8D6167B3C91','hex'),'BASIC_USER','kkirk'),
	('llee@revature.com',decode('FDC2138F6E699EE9E0177528F5A9863E','hex'),decode('51F96CABB82F528B019FF3329DBBD5A4F3E47D440DF0184ACE0027ABEFD62428D989042D3D9F92DF6BD2FD0206F1204CE241A44AA720BFB457EBB0E955858B4C7843F332611A90E94D85B4247B7BD4C011C70C783E1CC60BB97D94AC7A59CC607A6564AC9D5FE5730A84CB9A6E3BEF6F69EA71584F6FBBB491E351EF5C25CA2BFA4D5AECA01EE7CF36A705882832B4A8CC4CC002EB57B9E7D16122F3956DD9308D920994B00CC722ED072E0B60A3BBC1447DDE02883889C272C6E492CB15CF97167D5516EEFDFF3797E4A3677A477F4BCD69FFB70258ABB079DDFA10D5561A362CF11D4A9B87CB2248E3964BCDF4CE77C253A503B2BFEC29F1A8AFDAC5800189','hex'),'BASIC_USER','llee'),
	('mmurphy@revature.com',decode('173C46005B8944D2C9451E071E5F0ABA','hex'),decode('B25650924AD7D0974D42BCF67AC38CBB6783D3EC5F59D2326000CB360826211A5F24DF2E037C644B9AF599F39DD91352823BF4E8623462585A87B0C8758C48B5947DCF3834A959FADEF8BCADA2DE5A669BD1AFC8C81AC43D3F1DCDE5C1228644F81C387DBE3C9F31D97236180F52CE373FA0BF9390D1774F7BC58C9CA59441246DFC4F72BB263EA6FEA2A1E613344CD8F3F4F76EEB19882118124F06453BB3311504E54A68ABE2119BF0E631C492257329C63E3A9BFC3BE346A587AFD150C692BDE1CF8F26B25CEEF69E76C52D4BC8C635A04D9DAFFAA0FFF3AA1A5791375A7A468D6FE31CECFE83C75B7968D7A31C6CDFFA37B224751CFDA08DFBA1F94EC035','hex'),'BASIC_USER','mmurphy'),
	('nnorth@revature.com',decode('77B2C9CFE53061B038AD109C07816129','hex'),decode('C9F15FC83B2FEDA807146960A6C6BEBE08110BD108D098A0DC9574598BDC6902E17F7FA664EE9D2591974DB92507812961EDC90CC28DC6AB423B6EE88C9428A9D37EDF7CA782CE150F6F3CF0D329F134AA89ADE97B55ECE72684D079F15EAEF1A8611D00D97431634CE09A7597CADECFE3878DE1296D2E7077A740115A6E050D679DF81A6819F8F2A559C591E83F7CFBBF7E9E88707BB8AFD8FFAEFE4E77F006A75D0D68AF08760FD578540631AEBAB248DCDCD79FBF685C80B023A62E06642F4FD011AF03CAB3D09C63C75BA0562CA834253CED80048F2417992EEE98DF1A924FE991FA838D4EBA85746A1E46B823C5506F8564002E1EF0F261351C8D06DC1C','hex'),'BASIC_USER','nnorth'),
	('ooctavious@revature.com',decode('1F474A115A9F30BF9010638BBED6F01A','hex'),decode('B3B25B28905D43CB6420DA92EF7B1ACD55D2856C3EF6BF5B1700BC7B2C006196AC5055BE45806BA937A2103C25E789575DF392C740948C39336B5B6135B8D8B9491AE5E2E369152369CBAECB95402778B2AC208F7DEA8FBCA1B5A7066D09BC398786745096FE2F893D270758ABF9B9A2C79925B26A9D0E524AE7E18CE8E77A4D1224F301C117A0E542BCC59DED8D6D83D61D239DA98299E2766C404B4876B28E27905780E4B61CAF5F0F87F13CDFF81E4733322108AA4CD0B13023E21A881C377FCE34BE82342CD2AAC33D05D138AEDA4EB678A67AEA49F0CEAD040DED0EAEABDA1E261FFF22F3B14C9B7487F602D6D72789AA13C10EAEE92C9D7E7B353C6976','hex'),'BASIC_USER','ooctavious'),
	('pparker@revature.com',decode('1A7B80E6838F5E58E4BE62DDF0C7A7C5','hex'),decode('6DDD19EA1619080A7A6178777537B8E18ACEECCB50D00163C94CF4C3395C2E63F9782BA72A94EEC653E8118B3C0A868FFEA8939DC89E7B68364858590651800A032108C81EC8D3606386D21BDC984962CA76F852CD1094BE0FCD4D328F304F511BEF8915D018F965DA8D306B65F9A2AE9FB0D4CF6382753BB4E0DFAC47FDCFA6EE274883201D95533CDA425154030E18E4B1A34AC9684499CF313688109BB5FFDC13A9029506B1E0B952216425AF416403F2A445505DCB3557813F94C3C16A2FD7D38D4D9A53C0DADC48E654387BDD8158672AC95F3273003A94EDD9C05A80891265B8C12584886B9B4C526BF9AEC980D583F5CE90CB4B2E5DD49BD9CE67FE83','hex'),'BASIC_USER','pparker'),
	('qquartermaine@revature.com',decode('27288EC8C89B86D7310DB58E0D6D6B7C','hex'),decode('112ACF4714AECC38CC1784F61A6A0EB3B652005CFCA2535684A1425CAE1AC21B1C0B77E465768EB308E19981727F7F370DF6D4227E671FBA1D578C2AD39C3D9B71A1A6D87EA9DC0F4E9AE9C0C6FF1B3F6C4C5C574F261D31657006691BC9E95AEB5F129B95959931C080A5650D68044EC6A62E974FBEC4AE050C4DEFDF3DF06E414705586BBACE9E0B4684AE32A923DF5986F77CD56766A56961C3F3391B9C49536938A5CA40D26748380BE95B47520426F81C12DCFA9924E951794FA0438EA5B3C31D1F9CE69362AE39A776C2A3C535B1A130922E9C4DF3E65BB5BD54BB6A6037E481622F4AA37FB37A8E9E164887F4C35D9D20C1ACD79A7FC841FE3E93AA19','hex'),'BASIC_USER','qquartermaine'),
	('rrogers@revature.com',decode('E7C1C40BE3D87D3D539EB020258A237D','hex'),decode('575046F7C5A7CA7E24C53A3D35E16ADDB542C649BA17F620BFDC576F2B959EAC5BA922104B6BCF1BF523E4E0199486B254D7F5F24B2A73B0269A9EB4675A70E320A59B1A67EC3CC692931B26CA251AC978965F5CE7165DF3AD5526A6133FD0074551CCDB8EC76F2A477AA2023CE12A30B973569B0A4D3632039E82A630358F63B3F05337F3F1D4F7B90B9AD89A41F1E9BA08743A37ACDE66BC557AD3F86E3AC9FD0995138AD3D839AD92A3DBA01AA8F47060C73FDAA52BE44CBE83FC85F76EB4642C35E84FABD82393B4F1FD0B93DEE31B27DB042DD609890F412DBB08B1CF527DB1291AD6E47A0BBCF0841C86F872AC8B5D17C4AD8824DFD86B878490B6BBBD','hex'),'BASIC_USER','rrogers'),
	('ssmith@revature.com',decode('290E8EB3526941CC990C1A1EC8BAB2FA','hex'),decode('22C55095CD64ACBED076EA072EF0C0916EC3014AC0E2274258235F17B43850AB9036AD7C4B3F968850CFF1BB42EC586CF7F86DDAC252B80A7E10C569418AB1875C4BAD7A7CA33D4D0A232A7780E702E0258B91C17DC3D398E91267DA094780559B4C51ACC0D8F091C343E06F6AFC6EB5975E3C4F4412E9FDD4BC21744FE54E5BC64D58AEAA140C3860C79E33D1AE184F7A6FB1ABB2212A9C3E485DBD08213AD368AFB1969DE70F97357E71D90322C433C821044A4250437EF5F18E733930B8DA05B34EBDAED2021520D756413E8A94800B20E6A0C12B6481B3A074B23241CBB3110D8DC27846DE35992BB0800339361CB511409181EACE699994F979EE1B3B55','hex'),'BASIC_USER','ssmith'),
	('tturner@revature.com',decode('E5B39F01099F9FB5A11858D6177C0B9F','hex'),decode('68FA8D58883315B9816086D6719A246A944242560C9C7BA1487C418295B9C10CD9CCA348E245145D4DD913C5BE79FF6D87CF4C6B16EB5A12610C047E436B0A0A6AC49DD39B512EC1D040F60CB2F80504988BD26F8AE914A6C935698A0454EA1B0527647EA2B0A70C6AB9C3FBC60CFB60CFB07765793D6D0E6AE93BA724D8016A23B959D1CC4CC25C5B02107DDF3F817FF9750FC103E24D26721379CC5733E409626420EB94784A2DE52F52C3B92938A5CC58BD8472FDDF277FB3729CFC1FD108C7F0E7C89EDDD9F08FB46B2E33770C3D5E98C61A409629FABAEEE460E1BDF98DB72F7ABCE430844A81A3674DA863EA758EBD72E7ADBD8DF1623F342EA0AFC73D','hex'),'BASIC_USER','tturner'),
	('uunderhill@revature.com',decode('45BA4A66ABC115E70B195E155E97F02E','hex'),decode('34EADE0409C7FE224B851F1E7D2AF691B5BEA313181513231C32417EB6211D4CE2C67D0D38BF6BF20EEDD3FAE195BA0F63BFB1E2FE83D991A566078E5A667F1FBAD17186D12BC43982B7E7BDC05D5C2E6FBAA608EDB59292034BBC1BA627003ECE918635741AB95141D860D04618E251FAD9B5B1116C3CB8ABC7EAD3E13DC907B486F5DD0380CC3C175BAD36F761A075FF917DE7B2A8B00DE56CADFC1EF45366C7660FDCDF842FF39B9DB23893AE33C636BA54A34554E8C7C75A1F149416470818280C0C6929EDCE9E0F92AB9FCD5CADBBECB288290335F357E88FCCA4323856FDD832CD4068E135578C07CA81EF0171E6FED417A9D88163F8315A955FA73EEA','hex'),'BASIC_USER','uunderhill'),
	('vvincent@revature.com',decode('445F25E509DA17E41E93DFE1B46B84C2','hex'),decode('9687EAE9CDE5F63DEDD128242DDDD3BA8D05AABA288E5193D603809475CE6E00ECFD90267DA1698A909D462D84637C40D415AAAA3653D511ED5ADD1CC4706C7E784378C757D2D77432F8EAEF77D907D1BEAA993E513B3A215433D30AF3738674085232ED7F8E7BA66C156F5EDD36A1AE2E158402897C7BA0586744D63BBED596A026180359FBE42F586DF16748D25BB8ADF466F6B33ADDEA4B883D525784BC69E8E4FC849A09BD2D247C3832D46D6C916569AF6BB92D11DDF261D99B856D4DF79CFDD416BBBDA12ADC0C7006339FBBFB7140F3F87FF605EF02BCA1A10C98C7FB913D36449828A6E6708F0A45C44BF453E07721F91B02E4EAC873A6043BA23900','hex'),'BASIC_USER','vvincent'),
	('wwilson@revature.com',decode('D06B9DE69997B88F7B1A0002E2D271A5','hex'),decode('BF6AC4B70F8DCAABD5B5E7B7DDC50F37220D2FF8872490B8219E907CA9E4C76EA62E44CDC302494CCFF4F657D50925CACCF9E6F59DCAB39BEEC5B51A236108CD53902A8AD9D0D5855006026F9AAED539D2287A5DF3688E3D9822A55FC0A935DC276EA120269A85B9E74C4284E85E0489FCF7777C7E7E8A6B8385CA865031CC622474A737A704BCAAC63022616A694CA953BE2B757ADCBF03057998704480D03C17426F66E5ECC4A6EB1DE92577B54978331F01D5373D34E06E11F27BF2C52EA80EEF73A943D3F994D7EA16A30C20E1BCFFE3ADD636881439F7AD04D74443E6535AAAABFBB231FE152BC390947992CE6E20FF63270D209BA122FC1DB0BCA4D082','hex'),'BASIC_USER','wwilson'),
	('xxavier@revature.com',decode('77927636BFCC406E675E6E5A12586A54','hex'),decode('A3BC8F034F6B187EE4FCE9891B14FB10260B77160A75B477587CB78B2EE6307304A2C451D5F5DA83D249E9769797919D511BF2A66A0870A62E4393580643821FFDA02F804545367F9126B8628662D713F7A44B4F1D92EA14884386A193E1B0B2777885A0D5C2D4F0D9EF951AF969943A829CF7C18ECC54213EE9C4775A031F7B9DB6D5669FAE409A2CCD2A3FDCCD0D04D309BC65799D9FA8F530FF4BB91024868B2F8354592762F080A82507D28B61C1AEE5CD44F63EB2EBF123282A6E5E650D7CFF7B1900BC0BF5D8632B81DF6D6C5CDBAD33668C535053ADB0994D74246B80A44CB390F1519880F35443FC49CFAC3874DB5E58023ABE841803CB74551BF2BA','hex'),'BASIC_USER','xxavier'),
	('yyard@revature.com',decode('54C3B1C32783054760D1CA18E247C4B5','hex'),decode('595C35D1E9D3E9BD65E262141D04FB84BC81F5938B7897891530221F2197071F78C1A6017DC0162F09F04322F470762C64DCE5AAA21F511E4E6BAE88500584F61858EE4F24777FFD21DFCEBDD74AC655C7211AA22A966C1103F64D8910C6AD644AC247D72E4BEF95C2A7D8151BF42D66663A5FF1BE3DEACE7A0B8B117C639786FA258DD38758E2AFAC00D8EED842A330B85B81B0707586EB023FD7DEB2088641853385396098F1D22174136A03986E923E1D7276B7DD88B5497AEA14E6B3EA84FE645D55353065BEDBFBE6610B374A00082D39EC4597CC45F25BCB00754A133A5A3692323488690FB8E51E09084EF3C90B5B0AECFEC844F7644165F07D83DE3E','hex'),'BASIC_USER','yyard'),
	('zzabinski@revature.com',decode('8D9542311C5D5F9068D7DB0561165505','hex'),decode('012EE6A774411A8474F83BDD3E269297B56CC963F6963F512B4B1E06CFE3F5DF50FAB8A051CA5AC0C3A9F62F7F1F4CE6AFB36DF2234CDDA27FB9BE052C073FAF21523CE7521E479F72265853116400E7B77CA68FAE892F6D4F3CCF7072FA0AFDA1A43E80C62B16ACCCFA834883B22A9E994E7629CA43FC02FAE663A2FA4A52DCCAAC53A96FBD186B324E4EAC4680572278D665A2C3D59B2F16E09B73083BFC86C0F00487DCBC44A9F38A7409241F328C1F905AA5CF20D1019563EC608EB00BA2E415D8EB8412B73F514245265349D590D06F5F6AB3C53145842C51471387E25C4FB18D91C9B793D85EA201DA2C5A8E268AB82B5F302E4FD14492411E5105F8E0','hex'),'BASIC_USER','zzabinski')
;

insert into amg_restaurants (address, restaurant_name, place_id) 
values 
	('a.klsdhf', 'a;lsdkjf', 'qwiory'),
	('a.klhf', 'a;lsdkf', 'qweiry'),
	('a.klasdsdhf', ';lsdkjf', 'weiory'),
	('a.klsf', 'a;lsdadskjf', 'qry'),
	('a.kdhf', 'a;lsdk', 'qweioasdy')
;

insert into amg_likes 
values 
	(1, 1),
	(1, 2),
	(1, 3),
	(1, 4),
	(2, 1),
	(2, 2),
	(3, 1),
	(3, 2),
	(4, 5)
;

INSERT INTO amg_meals (final_restaurant_id, meal_name, num_votes)
VALUES 
	('qwiory', 'First Meal', 2)
	;

INSERT INTO amg_votes (amg_vote, vote_meal_id, restaurant_id, amg_user_id)
VALUES 
	(1, 1, 1, 1),
	(1, 1, 2, 1),
	(1, 1, 3, 1),
	(1, 1, 1, 2),
	(0, 1, 2, 2),
	(0, 1, 3, 2)
	;


-- +-------------------------------------------------------------+ 
-- +                    	  TESTING 
-- +-------------------------------------------------------------+ 

select * from amg_votes; 
select * from amg_meal_users; 
select * from amg_meal_restaurants; 
select * from amg_likes; 
select * from amg_meals; 
select * from amg_restaurants;
select * from amg_users;

INSERT INTO amg_votes (amg_vote, vote_meal_id, restaurant_id, amg_user_id)
VALUES (10, 5, 30, 2);



-- Custom query for getting winning restaurant of a vote
SELECT
    SUM (av.amg_vote) AS total,
    ar.restaurant_name,
    ar.address
FROM
    amg_votes av
JOIN 
	amg_restaurants ar
ON 
	av.restaurant_id = ar.amg_restaurant_id 
WHERE 
	av.vote_meal_id = 5
GROUP BY
    av.restaurant_id,
    ar.restaurant_name,
    ar.address
ORDER BY total DESC;





