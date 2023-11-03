@isTest
private class Test_BatchCovid19UpdateNotifierUser {
    @testSetup
    public static void setupTest() {
       CommonTestFunctions.commonSetup();
    }
    
    @isTest
    public static void batchUpdateNotifier() {        
        Covid19__c objCovid = new Covid19__c();
        Contact objContact = null;

        CommonTestFunctions.commonSetup();
        objContact = [SELECT Id, GUID__c FROM Contact LIMIT 1];
        try {
            objCovid.Citizen__c = objContact.Id;
            objCovid.GUID__c = objContact.GUID__c;

            insert objCovid;
            
        } catch (Exception Ex) {
            
        }

        objCovid.Notificacion_Date__c = Datetime.now();

        update objCovid;

        objCovid.Notifier_User__c = null;

        update objCovid;

        Test.startTest();

        Database.executeBatch(new BatchCovid19UpdateNotifierUser());

        Test.stopTest();
    }
}