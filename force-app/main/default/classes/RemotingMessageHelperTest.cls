@IsTest
private class RemotingMessageHelperTest {
    @testSetup
    private static void setupTest() {
        CommonTestFunctions.commonSetup(); 
    	createTerritory();
    }
    @IsTest
    private static void testRemotingObjectsTerritory() {
        RemotingMessageHelper.Territory objTerritory = null; 
        Territorio_Administrativo__c objTerritoryC = null;
        
        objTerritoryC = [SELECT Id, Name, Location_UUID__c, Total_Emails__c, Total_Facebook__c, Total_Hombres_de_65plus__c, Total_Instagram__c, Total_Linkedin__c, Total_Moviles__c, DeveloperName__c, Nivel_Administrativo__c, Flag__c, Total_Mujeres_de_0_a_15__c, ParentId__c, IsRole__c, SKU__c, Total_Number_of_00_15_year_olds__c, Total_Number_of_16_17_year_olds__c, Total_Number_of_18_24_year_olds__c, Total_Number_of_25_39_year_olds__c, Total_Number_of_40_64_year_olds__c, Total_Number_of_65_year_olds__c, Total_Number_of_Females__c, Total_Number_of_Males__c, Total_Mujeres_de_16_a_17__c, Total_Mujeres_de_18_a_24__c, Total_Mujeres_de_25_a_39__c, Total_Mujeres_de_40_a_64__c, Total_Mujeres_de_65Plus__c, Total_Telefonos_FIjos__c, Total_Twitter__c, Total_de_Hombres_de_0_a_15__c, Total_de_Hombres_de_40_a_64__c, Total_de_Hombres_de_25_a_39__c, Total_de_Hombres_de_18_a_24__c, Total_de_Hombres_de_16_a_17__c, Total_Ciudadanos__c, Social_Profiles__c, Level2Name__c, Level1Name__c, Level4Name__c, Level3Name__c, Level0Name__c 
                         FROM Territorio_Administrativo__c 
                        LIMIT 1];
        objTerritory = new RemotingMessageHelper.Territory(objTerritoryC);
        objTerritory = new RemotingMessageHelper.Territory(objTerritoryC, TRUE);
        
    }
    
    @IsTest
    private static void testRemotingObjectsUserPermission() { 
        RemotingMessageHelper.UserPermissions objUserPermission = null;
        
        objUserPermission = new RemotingMessageHelper.UserPermissions();

        RemotingMessageHelper.elmejortestlohacelusuarioenproduccion();
    }
    
      @IsTest
    private static void testRemotingObjectsMC() {  
    	RemotingMessageHelper.MarketingCloudAccessToken objAT = null;
        RemotingMessageHelper.EmailRequest objEmail = null;
        RemotingMessageHelper.SMSRequest objSMS  = null;
        RemotingMessageHelper.SMSResponses objSMSResponses  = null;
        
        objAT = new RemotingMessageHelper.MarketingCloudAccessToken();
        objAT.accessToken = 'test';
        objAT.expiresIn = 2600;
        
        objEmail = new RemotingMessageHelper.EmailRequest();
        objEmail.Sender = new RemotingMessageHelper.FromAddress();
        objEmail.Sender.Address = 'ppe';
        objEmail.Sender.Name = 'dfa';

        objEmail.To = new RemotingMessageHelper.ToAddress();
        objEmail.To.Address = 'test';
        objEmail.To.SubscriberKey = 'test';
        
        System.assertNotEquals(null, objEmail.ToJSON());
        
        objSMS = new RemotingMessageHelper.SMSRequest();
        objSMS.keyword = 'test';
        objSMS.Resubscribe = 'test';
        objSMS.Subscribe = 'test';
        
        objSMSResponses = new RemotingMessageHelper.SMSResponses();
        objSMSResponses.tokenId = 'test';
        
        objSMS.Subscribers.add(new RemotingMessageHelper.Subscriber());
        System.assertNotEquals(null, objSMS.ToJSON());

        RemotingMessageHelper.CountRecordsRequest objCountRecordsRequest = new RemotingMessageHelper.CountRecordsRequest();
        objCountRecordsRequest.type = 'type';
        objCountRecordsRequest.query = 'query';
        System.assertNotEquals(null, objCountRecordsRequest);


        RemotingMessageHelper.CountRecordsRespose objCountRecordsRespose = new RemotingMessageHelper.CountRecordsRespose();
        objCountRecordsRespose.code = 10;
        objCountRecordsRespose.message = 'message';
        objCountRecordsRespose.count = 10;
        System.assertNotEquals(null, objCountRecordsRespose);

    }
    
    @isTest
    private static void createCUITRequest() {
        RemotingMessageHelper.CUITRequest objCUIT = null;
        RemotingMessageHelper.CUITResponse objCUITReponse = null;
        
        objCUIT = new RemotingMessageHelper.CUITRequest();
        objCUIT.isValid();
        objCUIT.ExternalId = 'test';
        objCUIT.Client = 'Macro';
        objCUIT.BirthDay = 31;
        objCUIT.BirthMonth = 12;
        objCUIT.BirthYear = 2001;
        objCUIT.Email = 'juan.perez@prueba.com';
        objCUIT.FirstName = 'Juan';
        objCUIT.LastName = 'Perez';
        objCUIT.isValid();
        
        objCUIT = new RemotingMessageHelper.CUITRequest();
        
        objCUITReponse =  new RemotingMessageHelper.CUITResponse();
        objCUITReponse.Code = 100;
        objCUITReponse.CitizensFound = new List<RemotingMessageHelper.CitizenFound>();
        objCUITReponse.ExternalId = '23232';
        objCUITReponse.Message = 'test';
    }
    
    private static void createTerritory() {
          /* Test setup */
       Territorio_Administrativo__c terr = new Territorio_Administrativo__c();
       terr.Location_UUID__c = 'TEST';
       terr.Total_Ciudadanos__c = 100;
       terr.Total_de_Hombres_de_0_a_15__c = 100;
       terr.Total_Mujeres_de_0_a_15__c = 100;
       terr.Total_Emails__c = 100;
       terr.Total_Moviles__c = 100;
       terr.Total_Telefonos_FIjos__c = 100;
       terr.Total_Facebook__c = 100;
       terr.Total_Instagram__c = 100;
       terr.Total_Linkedin__c = 100;
       terr.Total_Twitter__c = 100;
       terr.Total_de_Hombres_de_16_a_17__c = 100;
       terr.Total_de_Hombres_de_18_a_24__c = 100; 
       terr.Total_de_Hombres_de_25_a_39__c = 100;
       terr.Total_de_Hombres_de_40_a_64__c = 100;
       terr.Total_Hombres_de_65plus__c = 100;
       terr.Total_Mujeres_de_16_a_17__c = 100;
       terr.Total_Mujeres_de_18_a_24__c = 100; 
       terr.Total_Mujeres_de_25_a_39__c = 100;
       terr.Total_Mujeres_de_40_a_64__c = 100;
       terr.Total_Mujeres_de_65plus__c = 100;
       insert terr;
    }
    
    @isTest
    private static void pulsoCRMObjectTest() {
        RemotingMessageHelper.Pulso objPulso = null;
        RemotingMessageHelper.PulsoSurvey objPulsoSurvey = null;
        RemotingMessageHelper.ProfileUser objProfileUser = null;
        RemotingMessageHelper.ProfileUserPermission objProfileUserPermission = null;
        RemotingMessageHelper.FieldPermission objFieldPermission = null;
        RemotingMessageHelper.SalesforceDoamins objSalesforceDoamins = null;
        RemotingMessageHelper.CommunitySettings objCommunitySettings = null;
        RemotingMessageHelper.MultipicklistOptions objMultipicklistOptions = null;
        RemotingMessageHelper.Citizen objCitizen = null;
        RemotingMessageHelper.CitizenFound objCitizenFound = null;
        RemotingMessageHelper.ChartData objChartData = new RemotingMessageHelper.ChartData();
        RemotingMessageHelper.ChartDataset objChartDataset = new RemotingMessageHelper.ChartDataset();
        RemotingMessageHelper.ChartOptions objChartOptions = new RemotingMessageHelper.ChartOptions();
        RemotingMessageHelper.ChartLegend objChartLegend = new RemotingMessageHelper.ChartLegend();
        RemotingMessageHelper.ChartTitle objChartTitle = new RemotingMessageHelper.ChartTitle();
        RemotingMessageHelper.ChartAnimation objChartAnimation = new RemotingMessageHelper.ChartAnimation();
        RemotingMessageHelper.ChartScale objChartScale = new RemotingMessageHelper.ChartScale();
        RemotingMessageHelper.ChartAxe objChartAxe = new RemotingMessageHelper.ChartAxe();
        RemotingMessageHelper.ChartScaleLabel objChartScaleLabel = new RemotingMessageHelper.ChartScaleLabel();
        RemotingMessageHelper.ChartGridLines objChartGridLines = new RemotingMessageHelper.ChartGridLines();
        RemotingMessageHelper.SearchResults objSearchResults = new RemotingMessageHelper.SearchResults([FIND 'FirstName' IN ALL FIELDS RETURNING Account(Name), Contact(FirstName,LastName) ]);
        RemotingMessageHelper.SearchResult objSearchResult = new RemotingMessageHelper.SearchResult([SELECT ID, FirstName, LastName FROM Contact]);

        objPulso = new RemotingMessageHelper.Pulso();
        objPulso.TypeFormUrl = 'test';
        objPulso.TwitterLink = 'test';
        objPulso.FacebookLink = 'test';
        objPulso.InstagramLink = 'test';
        objPulso.Domain = 'test';
        
        
        objPulsoSurvey = new RemotingMessageHelper.PulsoSurvey();
        objPulsoSurvey.Id = 'test';
        objPulsoSurvey.typeformid = 'test';
        objPulsoSurvey.advertisingid = 'test';
        objPulsoSurvey.name = 'test';
        objPulsoSurvey.description = 'test';
        objPulsoSurvey.preguntas = 1;
        objPulsoSurvey.surveyed = 2;
        //objPulsoSurvey.comentarios = 3;

        
        objProfileUser = new  RemotingMessageHelper.ProfileUser([SELECT Id, Name FROM Profile LIMIT 1]);
        objProfileUser = new  RemotingMessageHelper.ProfileUser([SELECT Id, Name, IsPortalEnabled, Username FROM User LIMIT 1]);

        objProfileUserPermission = new RemotingMessageHelper.ProfileUserPermission();
        objProfileUserPermission.TimeRange = 'test';
        objProfileUserPermission.MaxRecords = 10;
        objProfileUserPermission.Records = 10;
        objProfileUserPermission.Fields = new List<RemotingMessageHelper.FieldPermission>();
        
        objFieldPermission = new RemotingMessageHelper.FieldPermission();
        objFieldPermission.Id = 'id';
        objFieldPermission.Name = 'name';
        objFieldPermission.CanRead = true;
        objFieldPermission.CanWrite = true;
        objFieldPermission.CanExport = true;
        objFieldPermission.toSObject();
        
        objSalesforceDoamins = new RemotingMessageHelper.SalesforceDoamins();
        objSalesforceDoamins.LEX = 'ddd';
        objSalesforceDoamins.VF = 'fdasd';
        
        objCommunitySettings = new RemotingMessageHelper.CommunitySettings();
        objCommunitySettings.LEX = 'ddd';
        objCommunitySettings.VF = 'fdasd';
        objCommunitySettings.ContactLayout = 'ddd';
        
        objMultipicklistOptions = new RemotingMessageHelper.MultipicklistOptions();
        objMultipicklistOptions.label = '';
        objMultipicklistOptions.value = '';
        objMultipicklistOptions.selected = true;
        
        objCitizen = new RemotingMessageHelper.Citizen([SELECT Id, FirstName, LastName, Email, MobilePhone, PhotoUrl_legacy__c FROM Contact LIMIT 1]);
        objCitizenFound = new RemotingMessageHelper.CitizenFound([SELECT Id,Name, FirstName, LastName, Email, MobilePhone, PhotoUrl_legacy__c,Cuil_Number__c,BirthDate,Gender__c,Administrative_Level_1__c,Administrative_Level_2__c,Administrative_Level_3__c,Administrative_Level_4__c, Usuario_Facebook__c, Facebook_Link__c, ADFi_Profile_ID__c FROM Contact LIMIT 1]);
        

    }
}