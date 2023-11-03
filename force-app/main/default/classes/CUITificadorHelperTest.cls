@IsTest
private class CUITificadorHelperTest {
    @testSetup
    private static void setupTest() {
        Contact objContact = null;
        objContact = new Contact();
        objContact.FirstName = 'Juan';
        objContact.LastName = 'Perez';
        objContact.Email = 'juanperez@prosumia.la';
        objContact.Birthdate = Date.newInstance(1976, 3, 15);
        objContact.guid__c = '111';
        
        insert objContact;
    }
    
    @IsTest
    private static void cuitificateNoResultsTest() {
        Lead objLead = null;
        Contact objCitizen = null;
        
        objLead = new Lead();
        objLead.FirstName = 'Pedro';
        objLead.LastName = 'Perez';
        objLead.Email = 'pedroperez@prosumia.la';
        objLead.Company = 'Unit Test';
        objLead.Birthdate__c = Date.newInstance(1976, 3, 15);
        
        insert objLead;
        
        CUITificadorHelper.cuitificateLead(objLead);
        
        objCitizen = [SELECT Id FROM Contact];
        
        System.assertEquals(0, [SELECT Id FROM Lead WHERE Citizen__c =: objCitizen.Id ].size());        
    }
    
    @IsTest
    private static void cuitificateFirstNameLastNameBirthDateTest() {
        Lead objLead = null;
        Contact objCitizen = null;
        
        objLead = new Lead();
        objLead.FirstName = 'Juan';
        objLead.LastName = 'Perez';
        objLead.Email = 'pedroperez@prosumia.la';
        objLead.Company = 'Unit Test';
        objLead.Birthdate__c = Date.newInstance(1976, 3, 15);
        
        insert objLead;
        
        CUITificadorHelper.cuitificateLead(objLead);
        
        objCitizen = [SELECT Id FROM Contact];
        
        System.assertEquals(1, [SELECT Id FROM Lead WHERE Citizen__c =: objCitizen.Id ].size());        
    }
    
    @IsTest
    private static void cuitificateEmailBirthYearTest() {
        Lead objLead = null;
        Contact objCitizen = null;
        
        objLead = new Lead();
        objLead.FirstName = 'nocoincide';
        objLead.LastName = 'nocoincide';
        objLead.Email = 'juanperez@prosumia.la';
        objLead.Company = 'Unit Test';
        objLead.Birthdate__c = Date.newInstance(1976, 4, 5); //solo coincide email y año
        
        insert objLead;
        
        CUITificadorHelper.cuitificateLead(objLead);
        
        objCitizen = [SELECT Id FROM Contact];
        
        System.assertEquals(1, [SELECT Id FROM Lead WHERE Citizen__c =: objCitizen.Id ].size());        
    }
    
    @IsTest
    private static void cuitificateEmailBirthdateTest() {
        Lead objLead = null;
        Contact objCitizen = null;
        
        objLead = new Lead();
        objLead.FirstName = 'nocoincide';
        objLead.LastName = 'nocoincide';
        objLead.Email = 'juanperez@prosumia.la';
        objLead.Company = 'Unit Test';
        objLead.Birthdate__c = Date.newInstance(1976, 3, 15);        
        insert objLead;
        
        CUITificadorHelper.cuitificateLead(objLead);
        
        objCitizen = [SELECT Id FROM Contact];
        
        System.assertEquals(1, [SELECT Id FROM Lead WHERE Citizen__c =: objCitizen.Id ].size());        
    }
}