@isTest
private class RestMethodsControllerTest {
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
                objContact.FirstName = 'Juan Jose';
                objContact.LastName = 'Perez';
                objContact.Cuil_Number__c = '2011222333';
                objContact.Birthdate = Date.newInstance(2011, 11, 11);
                objContact.Email = 'mimail@mail.com';
                objContact.Gender__c = 'M';
                objContact.ADFi_Profile_ID__c = 54;
            } else if(intCount > 0 && intCount < 5) {
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
    private static void testCUITRequestEmpty() { 
        List<RemotingMessageHelper.CitizenFound> lstCitizensFound = null;
        Test.startTest();
        
        lstCitizensFound = RestMethodsController.retrieveCuits(new RemotingMessageHelper.CUITRequest());
        System.assertEquals(6, lstCitizensFound.size());
        
        lstCitizensFound = RestMethodsController.retrieveCuits(null);
        System.assertEquals(0, lstCitizensFound.size());
        
        Test.stopTest();        
    }
    
    @isTest
    private static void testCUITRequestExactMatch() { 
        List<RemotingMessageHelper.CitizenFound> lstCitizensFound = null;
        RemotingMessageHelper.CUITRequest objCUITRequest = null;
        Test.startTest();
        
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
        
        lstCitizensFound = RestMethodsController.retrieveCuits(objCUITRequest);
        System.assertEquals(1, lstCitizensFound.size());
        
        Test.stopTest();        
    }
    
    @isTest
    private static void testCUITRequestLessThan5() { 
        List<RemotingMessageHelper.CitizenFound> lstCitizensFound = null;
        RemotingMessageHelper.CUITRequest objCUITRequest = null;
        Test.startTest();
        
        objCUITRequest = new RemotingMessageHelper.CUITRequest();
        objCUITRequest.Client = 'Macro';        
        objCUITRequest.ExternalId = '123';           
        objCUITRequest.Email = 'common@mail.com';
        objCUITRequest.FirstName = 'Pedro';
        objCUITRequest.LastName = 'Rodriguez';        
        objCUITRequest.FullName = 'Pedro Rodriguez';
        objCUITRequest.Gender = 'M';
        
        lstCitizensFound = RestMethodsController.retrieveCuits(objCUITRequest);
        System.assertEquals(4, lstCitizensFound.size());
        
        Test.stopTest();        
    }
    
    @isTest
    private static void testCUITRequestMoreThan5() { 
        List<RemotingMessageHelper.CitizenFound> lstCitizensFound = null;
        RemotingMessageHelper.CUITRequest objCUITRequest = null;
        Test.startTest();
        
        objCUITRequest = new RemotingMessageHelper.CUITRequest();
        objCUITRequest.Client = 'Macro';        
        objCUITRequest.ExternalId = '123';           
        objCUITRequest.Email = 'common@mail.com';
        objCUITRequest.FirstName = 'Pablo';
        objCUITRequest.LastName = 'Perez';
        objCUITRequest.Gender = 'M';
        
        lstCitizensFound = RestMethodsController.retrieveCuits(objCUITRequest);
        System.assertEquals(5, lstCitizensFound.size());
        
        Test.stopTest();        
    }
}