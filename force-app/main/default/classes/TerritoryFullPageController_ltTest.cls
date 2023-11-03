@isTest
public class TerritoryFullPageController_ltTest {
    @isTest
    public static void simpleQueryTest () {
        Territorio_administrativo__c terr = CommonTestFunctions.createTerritorioAdministrativo('Territorio 0', null, 0);
        Test.startTest();
        List<Territorio_administrativo__c> terrList= TerritoryFullPageController_lt.getTerritoryById(terr.id);
        Test.stopTest();
        System.assertEquals(terrList[0].name, 'Territorio 0', 'El controller debe devolver el territorio correctamente');
    }

    @isTest  
    static void createLogTest() {      
        Territorio_administrativo__c terr = CommonTestFunctions.createTerritorioAdministrativo('Territorio 0', null, 0);
        Test.startTest();        
        TerritoryFullPageController_lt.createLog(terr.id);
        Test.stopTest();

        List<ActivityLog__c> logs = [SELECT Territory__c, logSource__c FROM ActivityLog__c];

        System.assertEquals(1, logs.size(), 'Se debe haber creado 1 log.');
        System.assertEquals(terr.id, logs[0].Territory__c, 'El log debe estar completo con el territorio que se visitó');
        System.assertEquals('CRM', logs[0].logSource__c, 'El log debe estar identificado como generado desde el CRM');
        
    }
}