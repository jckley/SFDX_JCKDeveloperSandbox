/**
* Class Name: ContactDetailControllerTest
* Description: Test Class for the ContactDetailController
* Developer: Luis Puentes - Date: 26/05/2018
*/

@isTest
public class ContactDetailControllerTest {
    @testSetup
    private static void setupTest() {
        System.debug('how many times is executed test setup?');
        CommonTestFunctions.commonSetup();                       
    }
    
    @isTest
    private static void testOrgVisibility() {
        System.assertNotEquals(0, [SELECT ID FROM PROFILE].size());
        System.assertNotEquals(0, [SELECT ID FROM User].size());
        //System.assertNotEquals(0, [SELECT ID FROM AsyncApexJob].size());
        System.assertNotEquals(0, [SELECT ID FROM CronTrigger].size());
    }
    
    @isTest 
    private static void testContactDetailController() {
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
     
        objContactWrapper = ContactDetailController.retrieveInfoFromCitizenId(objContact.Id);
        System.assertEquals(objContact.Id, objContactWrapper.citizen.Id);          
    }
    
    @isTest 
    private static void retrieveLoggedUserPermissionsTest() {
    	System.assertNotEquals(NULL, ContactDetailController.retrieveLoggedUserPermissions());
    }
    
    @isTest 
    private static void retrieveSalesforceDomainsTest() {
    	System.assertNotEquals(NULL, ContactDetailController.retrieveSalesforceDomains());
    }
    
    @isTest 
    private static void retrieveMultipicklistOptionsTest() {        
    	System.assertNotEquals(NULL, ContactDetailController.retrieveMultipicklistOptions('Contact','Community__c'));
    }
    
    @isTest
    private static void retrieveLayoutTest() {       
        String strJSON = NULL;
        
        strJSON = ContactDetailController.retrieveLayout();
        
    	System.assertNotEquals(NULL, strJSON);
    }
}