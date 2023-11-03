@isTest
private class RestMethodsTest {
    @testSetup
    private static void setupTest() {
        List<Contact> lstContact = null;
        Integer intCount = null;
        CommonTestFunctions.commonSetup();
        
        lstContact = [SELECT ID
                      FROM Contact];
        intCount = 0;
        for(Contact objContact : lstContact) {
            if(intCount == 0) {
                objContact.FirstName = 'Juan';
                objContact.LastName = 'Perez';
                objContact.Cuil_Number__c = '2011222333';
                objContact.Birthdate = Date.newInstance(2011, 11, 11);
                objContact.Email = 'mimail@mail.com';
                objContact.Gender__c = 'M';
                objContact.ADFi_Profile_ID__c = 54;
            } else if(intCount > 0 && intCount < 3) {
                objContact.FirstName = 'Pedro';
                objContact.LastName = 'Rodriguez';
                objContact.Cuil_Number__c = String.format('2011222333{0}', new String[] { String.valueOf( intCount)});
                objContact.Birthdate = Date.newInstance(2011, 11, intCount);
                objContact.Email = 'common@mail.com';
                objContact.Gender__c = 'M';
                objContact.ADFi_Profile_ID__c = intCount;
            } else {
                objContact.FirstName = 'Pablo';
                objContact.LastName = 'Perez';
                objContact.Cuil_Number__c = String.format('2011222333{0}', new String[] { String.valueOf(intCount)});
                objContact.Birthdate = Date.newInstance(2011, 11, intCount);
                objContact.Email = 'common@mail.com';
                objContact.Gender__c = 'M';
                objContact.ADFi_Profile_ID__c = intCount;
            }
            
            intCount++;
        }
        
        update lstContact;
    }
    
    @isTest
    private static void testIsAlive() {  
        System.assertEquals('isAlive!', RestMethods.isAlive()) ;    
    }
    
    @isTest
    private static void testCUITRequestEmpty() { 
        List<RemotingMessageHelper.CUITRequest> lstCUITRequest = null;
        RemotingMessageHelper.CUITRequest objCUITRequest = null;
        Test.startTest();
        
        setupRESTContext();
        
        RestMethods.retrieveCuits(lstCUITRequest);
        lstCUITRequest = new List<RemotingMessageHelper.CUITRequest>();
        RestMethods.retrieveCuits(lstCUITRequest);
        
        objCUITRequest = new RemotingMessageHelper.CUITRequest();
        lstCUITRequest.add(objCUITRequest);
        RestMethods.retrieveCuits(lstCUITRequest);
        
        Test.stopTest();        
    }
    
    @isTest
    private static void testCUITRequestExactMatch() { 
        List<RemotingMessageHelper.CUITRequest> lstCUITRequest = null;
        RemotingMessageHelper.CUITRequest objCUITRequest = null;
        Test.startTest();
        
        setupRESTContext();
        
        RestMethods.retrieveCuits(lstCUITRequest);
        lstCUITRequest = new List<RemotingMessageHelper.CUITRequest>();
        
        objCUITRequest = new RemotingMessageHelper.CUITRequest();
        objCUITRequest.Client = 'Macro';        
        objCUITRequest.ExternalId = '123';
        objCUITRequest.BirthDay = 11;
        objCUITRequest.BirthMonth = 11;
        objCUITRequest.BirthYear = 2011;            
        objCUITRequest.Email = 'mimail@mail.com';
        objCUITRequest.FirstName = 'Juan';
        objCUITRequest.LastName = 'Perez';
        objCUITRequest.Gender = 'M';
        objCUITRequest.AdFiProfileId = 54;
        lstCUITRequest.add(objCUITRequest);
        
        RestMethods.retrieveCuits(lstCUITRequest);
        
        Test.stopTest();        
    }
    
    @isTest
    private static void testCUITRequestLessThan5() { 
        List<RemotingMessageHelper.CUITRequest> lstCUITRequest = null;
        RemotingMessageHelper.CUITRequest objCUITRequest = null;
        Test.startTest();
        
        setupRESTContext();
        
        RestMethods.retrieveCuits(lstCUITRequest);
        lstCUITRequest = new List<RemotingMessageHelper.CUITRequest>();
        
        objCUITRequest = new RemotingMessageHelper.CUITRequest();
        objCUITRequest.Client = 'Macro';        
        objCUITRequest.ExternalId = '123';           
        objCUITRequest.Email = 'common@mail.com';
        objCUITRequest.FirstName = 'Pedro';
        objCUITRequest.LastName = 'Rodriguez';
        objCUITRequest.Gender = 'M';
        lstCUITRequest.add(objCUITRequest);
        
        RestMethods.retrieveCuits(lstCUITRequest);
        
        Test.stopTest();        
    }
    
    @isTest
    private static void testCUITRequestMoreThan5() { 
        List<RemotingMessageHelper.CUITRequest> lstCUITRequest = null;
        RemotingMessageHelper.CUITRequest objCUITRequest = null;
        Test.startTest();
        
        setupRESTContext();
        
        RestMethods.retrieveCuits(lstCUITRequest);
        lstCUITRequest = new List<RemotingMessageHelper.CUITRequest>();
        
        objCUITRequest = new RemotingMessageHelper.CUITRequest();
        objCUITRequest.Client = 'Macro';        
        objCUITRequest.ExternalId = '123';           
        objCUITRequest.Email = 'common@mail.com';
        objCUITRequest.FirstName = 'Pablo';
        objCUITRequest.LastName = 'Perez';
        objCUITRequest.Gender = 'M';
        lstCUITRequest.add(objCUITRequest);
        
        RestMethods.retrieveCuits(lstCUITRequest);
        
        Test.stopTest();        
    }
    
     @isTest
    private static void testCUITRequestNoRecordsFound() { 
        List<RemotingMessageHelper.CUITRequest> lstCUITRequest = null;
        RemotingMessageHelper.CUITRequest objCUITRequest = null;
        Test.startTest();
        
        setupRESTContext();
        
        RestMethods.retrieveCuits(lstCUITRequest);
        lstCUITRequest = new List<RemotingMessageHelper.CUITRequest>();
        
        objCUITRequest = new RemotingMessageHelper.CUITRequest();
        objCUITRequest.Client = 'Macro';        
        objCUITRequest.ExternalId = '123';           
        objCUITRequest.Email = 'norecordsfound@mail.com';
        objCUITRequest.FirstName = 'Pablo';
        objCUITRequest.LastName = 'Perez';
        objCUITRequest.Gender = 'M';
        lstCUITRequest.add(objCUITRequest);
        
        RestMethods.retrieveCuits(lstCUITRequest);
        
        Test.stopTest();        
    }
    @isTest
    private static void testMoreThan100Request() {
        List<RemotingMessageHelper.CUITRequest> lstCUITRequest = null;
        RemotingMessageHelper.CUITRequest objCUITRequest = null;
        
        Test.startTest();
        setupRESTContext();
        lstCUITRequest = new List<RemotingMessageHelper.CUITRequest>();
        for(Integer intIndex = 0; intIndex <= 200; intIndex++) {
            objCUITRequest = new RemotingMessageHelper.CUITRequest();
            lstCUITRequest.add(objCUITRequest);            
        }
        
        RestMethods.retrieveCuits(lstCUITRequest);
        Test.stopTest();
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
    
    /*
@testSetup
private static void setupTest() {
createCitizen();
}

@isTest
private static void testCUITRequest() {
RemotingMessageHelper.CUITRequest objCUIT = null;
List<RemotingMessageHelper.CUITRequest> lstCUITS = null;
Test.startTest();
setupRESTContext();

lstCUITS = new  List<RemotingMessageHelper.CUITRequest>();
RestMethods.retrieveCUITS(lstCUITS);


objCUIT = new RemotingMessageHelper.CUITRequest();
lstCUITS.add(objCUIT);

objCUIT = new RemotingMessageHelper.CUITRequest();
objCUIT.Client = 'Macro';
objCUIT.Email = 'juan.perez@prueba.com';
objCUIT.FirstName = 'Juan';
objCUIT.LastName = 'Perez';
lstCUITS.add(objCUIT);

objCUIT = new RemotingMessageHelper.CUITRequest();
objCUIT.Client = 'Macro';
objCUIT.Email = 'juan.perez@prueba.com';
objCUIT.FirstName = 'Juan';
objCUIT.LastName = 'Perez';
lstCUITS.add(objCUIT);

objCUIT = new RemotingMessageHelper.CUITRequest();
objCUIT.Client = 'Macro';
objCUIT.Email = 'juan.perez@prueba.comd';
objCUIT.FirstName = 'Juan';
objCUIT.LastName = 'Perez';
lstCUITS.add(objCUIT);

objCUIT = new RemotingMessageHelper.CUITRequest();
objCUIT.Client = 'Macro';
objCUIT.Email = 'juan.perez@prueba.com';
objCUIT.FirstName = 'Juan';
objCUIT.LastName = 'Perez';
lstCUITS.add(objCUIT);

RestMethods.retrieveCUITS(lstCUITS);
RestMethods.isAlive();

Test.stopTest();

System.debug('insertValidPayment_Test [] <-');
}

@isTest
private static void test100CUITRequest() {
RemotingMessageHelper.CUITRequest objCUIT = null;
List<RemotingMessageHelper.CUITRequest> lstCUITS = null;
Test.startTest();
setupRESTContext();

lstCUITS = new  List<RemotingMessageHelper.CUITRequest>();        

for(Integer intIndex = 0; intIndex <= 100; intIndex++) {
objCUIT = new RemotingMessageHelper.CUITRequest();
objCUIT.Client = 'Macro';
objCUIT.BirthDay = 31;
objCUIT.BirthMonth = 12;
objCUIT.BirthYear = 2010;            
objCUIT.Email = 'juan.perez@prueba.com';
objCUIT.FirstName = 'Juan';
objCUIT.LastName = 'Perez';
lstCUITS.add(objCUIT);            
}
RestMethods.retrieveCUITS(lstCUITS);

Test.stopTest();

System.debug('insertValidPayment_Test [] <-');
}

@isTest
private static void testDuplicatedCUITRequest() {
RemotingMessageHelper.CUITRequest objCUIT = null;
List<RemotingMessageHelper.CUITRequest> lstCUITS = null;
Test.startTest();
setupRESTContext();
createDuplicateCitizen();

lstCUITS = new  List<RemotingMessageHelper.CUITRequest>();        

objCUIT = new RemotingMessageHelper.CUITRequest();
objCUIT.Client = 'Macro';
objCUIT.Email = 'juan.perez@prueba.com';
objCUIT.FirstName = 'Juan';
objCUIT.LastName = 'Perez';
lstCUITS.add(objCUIT);            

RestMethods.retrieveCUITS(lstCUITS);

Test.stopTest();

System.debug('insertValidPayment_Test [] <-');
}
private static void createCitizen() {
Contact objContact = null;

objContact = new Contact();
objContact.FirstName = 'Juan';
objContact.LastName = 'Perez';
objContact.Email = 'juan.perez@prueba.com';
objContact.Birthdate = Date.newInstance(2000, 12, 31);
objContact.Cuil_Number__c = '27251112228';
objContact.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' LIMIT 1].Id;

insert objContact;        
}

private static void createDuplicateCitizen() {
Contact objContact = null;

objContact = new Contact();
objContact.FirstName = 'Juan';
objContact.LastName = 'Perez';
objContact.Email = 'juan.perez@prueba.com';
objContact.Birthdate = Date.newInstance(2000, 12, 31);
objContact.Cuil_Number__c = '27251112229';
objContact.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' LIMIT 1].Id;

insert objContact;        
}

*/
}