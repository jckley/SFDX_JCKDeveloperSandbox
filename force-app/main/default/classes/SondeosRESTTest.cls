@IsTest
private class SondeosRESTTest {
    @TestSetup
    private static void setupTest() {
        Campania__c objCampania = null;
        Message__c objMessage = null;

        objCampania = createCampania();
        objMessage = createMesssage(objCampania);
    }

    @IsTest
    private static void isAliveTest() {
        setupRESTContext();
        
        System.assertEquals('isAlive!', SondeosREST.isAlive());
    }

    @IsTest
    private static void updateStatsTest() {
        String strStatType = null;
        String strMessageId = null;
        Integer intSends = null;
        Campania__c objCampania = null;
        Message__c objMessage = null;

        setupRESTContext();

        strMessageId = [SELECT Id FROM Message__c LIMIT 1].Id;

        SondeosREST.updateStats(strStatType, strMessageId, 123);

        objCampania = [SELECT Status__c FROM Campania__c];

        System.assertEquals('FINALIZADA', objCampania.Status__c);
        objMessage = [SELECT TotalsSent__c, TotalsAudience__c FROM Message__c];

        System.assertEquals(123, objMessage.TotalsSent__c);
        System.assertEquals(123, objMessage.TotalsAudience__c);
    }

    private static Campania__c  createCampania() {
        Project__c objProject = new Project__c();
        objProject.Prioridad__c = 2;
        objProject.Objetivo__c = 'objetivo';
        insert objProject;

        Campania__c objCampania = null;

        objCampania = new Campania__c();
        objCampania.Name = 'Test';
        objCampania.StartDate__c = Date.today();
        objCampania.EndDate__c = Date.today();
        objCampania.Status__c = 'In Progress';
        objCampania.Project__c = objProject.Id;

        insert objCampania;

        return objCampania;
    }

    private static Message__c createMesssage(Campania__c objCampania) { 
        Message__c objMessage = null;

        objMessage = new Message__c();
        objMessage.Campania__c = objCampania.Id;
        objMessage.Body__c = 'Mensaje de prueba';
        objMessage.CantRejected__c = 0;
        objMessage.CantSuccess__c  = 0;
        objMessage.Receiver__c = '123';
        objMessage.Receiver_id__c = '123';
        objMessage.SendDateTime__c = DateTime.now();
        objMessage.Sender__c = '0';
        objMessage.TotalsAudience__c = 0;
        objMessage.TotalsSent__c = 0;

        insert objMessage;

        return objMessage;
    }

    private static void setupRESTContext() {
        RestRequest objRESTRequest = null; 
        RestResponse objRESTResponse = null;
        
        objRESTRequest = new RestRequest(); 
        objRESTResponse = new RestResponse();
        
        objRESTRequest.requestURI = 'https://www.salesforce.com';
        objRESTRequest.httpMethod = 'POST';
        
        RestContext.request = objRESTRequest;
        RestContext.response = objRESTResponse;
        
    }
}