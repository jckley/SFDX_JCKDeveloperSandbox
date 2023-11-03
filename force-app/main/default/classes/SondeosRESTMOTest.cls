@IsTest
private class SondeosRESTMOTest {
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
        
        System.assertEquals('isAlive!', SondeosRESTMO.isAlive());
    }


    @IsTest
    private static void updateResponseTest() {
        RemotingMessageHelper.SondeosMO objRequest = null; 

        objRequest = new RemotingMessageHelper.SondeosMO();
        objRequest.auth = new RemotingMessageHelper.SondeosAuth();
        objRequest.auth.usuario = 'user';
        objRequest.auth.password = 'password';
        objRequest.options = new List<RemotingMessageHelper.SondeosOption>();
        objRequest.parameters =  new RemotingMessageHelper.SondeosParametersMO();

        objRequest.parameters.telco = 'Claro';
        objRequest.parameters.customerId = [SELECT Id FROM Message__c LIMIT 1].Id;
        objRequest.parameters.destino = (Long)5491167304156L;
        objRequest.parameters.fecha = 'test';
        objRequest.parameters.mensaje = '12334mkfmfdkas';
        objRequest.parameters.origen = 87888;
        objRequest.parameters.origenRotativo = 87888;

        /*
        objRequest.parameters.celco = 'Claro';
        objRequest.parameters.customerId = [SELECT Id FROM Message__c LIMIT 1].Id;
        objRequest.parameters.destino = 5491167304156
        objRequest.parameters.estado = 2;
        objRequest.parameters.id_mensaje = '12334mkfmfdkas';
        objRequest.parameters.msgId = null;
        objRequest.parameters.origen = 87888;
        objRequest.parameters.origenRotativo = 87888;
        objRequest.parameters.shortMessageDR = null;
        */

        setupRESTContext();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(objRequest));
        
        SondeosRESTMO.updateResponse();

        System.assertEquals(1, [SELECT Id FROM SMS_Response__c].size());
        System.assertEquals(1, [SELECT Id FROM Response__c].size());        
    }

    @IsTest
    private static void updateStatsTest() {
        String strStatType = null;
        String strMessageId = null;
        Integer intSends = null;
        Message__c objMessage = null;

        setupRESTContext();

        strMessageId = [SELECT Id FROM Message__c LIMIT 1].Id;

        SondeosRESTMO.updateStatistics(strStatType, strMessageId, 123);

        objMessage = [SELECT TotalsSent__c, TotalsAudience__c FROM Message__c];

        System.assertEquals(123, objMessage.TotalsSent__c);
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