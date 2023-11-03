@isTest
private class ProsumerIvrRESTInterfaceTest {

	@testSetup
    private static void setupTest() {
        Project__c objProject = new Project__c();
        objProject.Prioridad__c = 2;
        objProject.Objetivo__c = 'objetivo';
        insert objProject;
        
        Campania__c campania = new Campania__c (Project__c = objProject.Id, name='Campaña de navidad', StartDate__c=Date.newInstance(2019, 7, 7), Status__c='FINALIZADA');
        campania.Prosumer_Sondeos_IVR_Campaign_Id__c = 'Test Campaign Id';        
        insert campania;        
    }
    

    @isTest
    static void testUpdateCampanias() {
        List<ProsumerIvrRESTInterface.Stats> lstStats = new List<ProsumerIvrRESTInterface.Stats>();
        ProsumerIvrRESTInterface.Stats stats = new ProsumerIvrRESTInterface.Stats();
        stats.id = 'Test Campaign Id';
        stats.name = 'Test Campaign';
        stats.type = 'Test Type';
        stats.status = 'Finished';
        stats.from_date = '2023-07-24';
        stats.until_date = '2023-07-25';
        stats.processed_cases = 100;
        stats.contacted_cases = 80;
        stats.processed_percent = 80.0;
        stats.total_cases = 200;
        lstStats.add(stats);

        // Test the HTTP POST method
        Test.startTest();
        Integer result = ProsumerIvrRESTInterface.updateCampanias(lstStats);
        Test.stopTest();

        // Verify that the records are updated as expected
        List<Campania__c> updatedCampanias = [SELECT Prosumer_Cantidad_Enviados__c, Prosumer_Cantidad_Entregados__c,
                                              Prosumer_Cantidad_No_Entregados__c, Prosumer_Estado__c
                                              FROM Campania__c WHERE Prosumer_Sondeos_IVR_Campaign_Id__c = 'Test Campaign Id'];

        System.assertEquals(1, updatedCampanias.size());
        Campania__c updatedCampania = updatedCampanias[0];
        System.assertEquals(100, updatedCampania.Prosumer_Cantidad_Enviados__c);
        System.assertEquals(80, updatedCampania.Prosumer_Cantidad_Entregados__c);
        System.assertEquals(20, updatedCampania.Prosumer_Cantidad_No_Entregados__c);
        System.assertEquals('Cerrado', updatedCampania.Prosumer_Estado__c);
    }
    
}