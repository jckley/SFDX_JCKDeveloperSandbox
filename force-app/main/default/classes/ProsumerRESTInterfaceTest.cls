@isTest
private class ProsumerRESTInterfaceTest {

    @isTest
    static void testUpdateCampanias() {
        
        
        // Create test data
        Project__c project = new Project__c();
        project.Name = 'Test Project';
        insert project;

        Campania__c testCampania = new Campania__c(
            Name = 'Test Campaign',
            Prosumer_Mensaje_SMS__c = 'Test Message',
            Project__c = project.Id
        );
        insert testCampania;

        ProsumerRESTInterface.Stats testStats = new ProsumerRESTInterface.Stats();
        testStats.intMCCampaignId = 1234;
        testStats.strMessage = 'Test Message';
        testStats.intMessagesSent = 10;
        testStats.intMessagesDelivered = 8;
        testStats.intMessagesUndelivered = 2;

        List<ProsumerRESTInterface.Stats> testStatsList = new List<ProsumerRESTInterface.Stats>();
        testStatsList.add(testStats);

        // Call the method being tested
        Test.startTest();
        ProsumerRESTInterface.updateCampanias(testStatsList);
        Test.stopTest();

        // Verify that the Campania__c record was updated correctly
        Campania__c updatedCampania = [SELECT Id, Prosumer_Cantidad_Enviados__c, Prosumer_Cantidad_Entregados__c, Prosumer_Cantidad_No_Entregados__c, Mobile_Connect_Campaign_Id__c, Message_Tracking_Last_Update__c, Prosumer_Estado__c FROM Campania__c WHERE Id = :testCampania.Id];
        System.assertEquals(10, updatedCampania.Prosumer_Cantidad_Enviados__c);
        System.assertEquals(8, updatedCampania.Prosumer_Cantidad_Entregados__c);
        System.assertEquals(2, updatedCampania.Prosumer_Cantidad_No_Entregados__c);
        System.assertEquals(1234, updatedCampania.Mobile_Connect_Campaign_Id__c);
        System.assertEquals('Send Automation en ejecución', updatedCampania.Prosumer_Estado__c);
    }
    
    @isTest
    static void testUpdateCampanias2() {
        
        // Create test data
        Project__c project = new Project__c();
        project.Name = 'Test Project 2';
        insert project;
        
        Campania__c testCampania2 = new Campania__c(
            Name = 'Test Campaign',
            Prosumer_Mensaje_SMS__c = 'Test Message 2',
            Project__c = project.Id,
            Mobile_Connect_Campaign_Id__c = 4567,
            Prosumer_Cantidad_Enviados__c = 0,
            Prosumer_Cantidad_Entregados__c = 0,
            Prosumer_Cantidad_No_Entregados__c = 0
        );
        insert testCampania2;

        ProsumerRESTInterface.Stats testStats2 = new ProsumerRESTInterface.Stats();
        testStats2.intMCCampaignId = 4567;
        testStats2.strMessage = 'Test Message 2';
        testStats2.intMessagesSent = 10;
        testStats2.intMessagesDelivered = 9;
        testStats2.intMessagesUndelivered = 1;

        List<ProsumerRESTInterface.Stats> testStatsList2 = new List<ProsumerRESTInterface.Stats>();
        testStatsList2.add(testStats2);

        // Call the method being tested
        Test.startTest();
        ProsumerRESTInterface.updateCampanias(testStatsList2);
        Test.stopTest();

        // Verify that the Campania__c record was updated correctly
        Campania__c updatedCampania2 = [SELECT Id, Prosumer_Cantidad_Enviados__c, Prosumer_Cantidad_Entregados__c, Prosumer_Cantidad_No_Entregados__c, Mobile_Connect_Campaign_Id__c, Message_Tracking_Last_Update__c, Prosumer_Estado__c FROM Campania__c WHERE Id = :testCampania2.Id];
        System.assertEquals(10, updatedCampania2.Prosumer_Cantidad_Enviados__c);
        System.assertEquals(9, updatedCampania2.Prosumer_Cantidad_Entregados__c);
        System.assertEquals(1, updatedCampania2.Prosumer_Cantidad_No_Entregados__c);
        System.assertEquals(4567, updatedCampania2.Mobile_Connect_Campaign_Id__c);
        System.assertEquals('Cerrado', updatedCampania2.Prosumer_Estado__c);
        
    }
    
}