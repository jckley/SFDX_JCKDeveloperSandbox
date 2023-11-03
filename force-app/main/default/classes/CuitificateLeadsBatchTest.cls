@IsTest
private class CuitificateLeadsBatchTest {
    @testSetup
    private static void setupTest() {
        Contact objContact = null;
        objContact = new Contact();
        objContact.FirstName = 'Juan';
        objContact.LastName = 'Perez';
        objContact.Email = 'juanperez@prosumia.la';
        objContact.Birthdate = Date.newInstance(1976, 3, 15);
        objContact.guid__c = '222';
        
        insert objContact;
        
        Lead objLead = null;
        
        objLead = new Lead();
        objLead.FirstName = 'Juan';
        objLead.LastName = 'Perez';
        objLead.Email = 'pedroperez@prosumia.la';
        objLead.Company = 'Unit Test';
        objLead.Birthdate__c = Date.newInstance(1976, 3, 15);
        
        insert objLead;
    }
    
    @IsTest
    private static void cuitificateBatchTest() {
		CuitificateLeadsBatch objBatch = null;
        
        objBatch = new CuitificateLeadsBatch();
        
        Test.startTest();
        Database.executeBatch(objBatch);
        Test.stopTest();     	           
    }
}