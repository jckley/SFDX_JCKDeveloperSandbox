/**
* Class Name: CommunitiesControllerTest
* Description: Test Class for the CommunitiesController
* Developer: José Gerstner - Date: 17/05/2021
*/

@isTest
public class CommunitiesControllerTest {
    @testSetup
    private static void setupTest() {
        CommonTestFunctions.commonSetup();                       
    }
    
    @isTest 
    private static void testCommunitiesController() {
        Contact objContact = null;
		ApexPages.StandardController objStandardController = null;
        ContactDetailController objContactDetailController = null;
        CitizenWrapper objContactWrapper = null;
        
        objContact = CommonTestFunctions.retrieveContact();
        System.assertEquals(TRUE, ContactDetailController.saveMultipicklistOptions(objContact.Id, 'Contact', 'Community__c', new String[] {'hola', 'mundo'})); 

        objStandardController = new ApexPages.StandardController(objContact);
        objContactDetailController = new ContactDetailController (objStandardController);
        objContactDetailController.saveContact();
        
        System.assertEquals(objContact.Id, objContactDetailController.contact.Id);
        System.assertEquals(objContact.Id, objContactDetailController.conId);
        System.assertEquals(objContact.Id, objContactDetailController.contWrap.contact.Id);     
        System.assertNotEquals(NULL, objContactDetailController.contWrap.personAddressSearch); 
        //System.assertNotEquals(NULL, objContactDetailController.contWrap.tags);     
     
        objContactWrapper = CommunitiesController.retrieveInfoFromCitizenId(objContact.Id);
        System.assertEquals(objContact.Id, objContactWrapper.citizen.Id);          
    }
    
    @IsTest
    private static void retrieveSiteTest() {
        CommunitiesController.retrieveSite();
    }
    
    @isTest  
    static void retriveTerritory() {              
        CommunitiesController.getRootTerritory();
    }

    @isTest  
    static void createLogTest() {      
        Contact ct = new Contact ();
        ct.FirstName = 'testName';
        ct.LastName = 'testLstName';
        ct.guid__c = 'asd123123';
        insert ct;

        Test.startTest();        
        CommunitiesController.createLog(ct.id);
        Test.stopTest();

        List<ActivityLog__c> logs = [SELECT Citizen__c, logSource__c FROM ActivityLog__c];

        System.assertEquals(1, logs.size(), 'Se debe haber creado 1 log.');
        System.assertEquals(ct.id, logs[0].Citizen__c, 'El log debe estar completo con el ciudadano que se visitó');
        System.assertEquals('CRM', logs[0].logSource__c, 'El log debe estar identificado como generado desde el CRM');
        
    }
}