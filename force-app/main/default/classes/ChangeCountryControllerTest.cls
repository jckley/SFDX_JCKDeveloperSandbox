@IsTest
public class ChangeCountryControllerTest {
    private static String DEFAULT_USERNAME = 'matias.rodriguez@prosumia.la.test';
    @testSetup
    private static void setupTest() {
        createUser();
    }
    
    @isTest
    private static void changeCountry() {
        User objUser = null;
        User objUserTest = null;
        
        objUser = [SELECT ID FROM User WHERE Username =: DEFAULT_USERNAME]; 
        Test.startTest();
        System.runAs(objUser) {
            ChangeCountryController.retrieveCountries();
            ChangeCountryController.changeCountryInSF('Territory_Argentina');             
        }        
        Test.stopTest();
    }
    
    private static void createUser() {
        User objUser = null;
        
        objUser = new User();
        objUser.Email = 'matias.rodriguez@prosumia.la';
        objUser.Username = DEFAULT_USERNAME;
        objUser.LastName = 'Rodriguez Llanos';
        objUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
        objUser.Alias = 'en_US';
        objUser.TimeZoneSidKey = 'America/Argentina/Buenos_Aires';
        objUser.LocaleSidKey = 'en_US';
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.LanguageLocaleKey = 'en_US';
     
        insert objUser;
    }
}