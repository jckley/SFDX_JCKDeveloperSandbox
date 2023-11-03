/**
* Class Name: CommunitiesChileControllerTest
* Description: Test Class for the CommunitiesChileController
* Developer: José Gerstner - Date: 24/02/2022
*/

@isTest
public class CommunitiesChileControllerTest {
    @testSetup
    private static void setupTest() {
        CommonTestFunctions.commonChileSetup();                       
    }
    
    @isTest 
    private static void testCommunitiesChileController() {
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
     
        objContactWrapper = CommunitiesChileController.retrieveInfoFromCitizenId(objContact.Id);
        System.assertEquals(objContact.Id, objContactWrapper.citizen.Id);          
    }
    
    @IsTest
    private static void retrieveSiteTest() {
        CommunitiesChileController.retrieveSite();
    }
    
    @isTest  
    static void retriveTerritory() {              
        CommunitiesChileController.getRootTerritory();
    }
}