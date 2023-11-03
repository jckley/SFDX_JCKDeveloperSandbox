@IsTest(SeeAllData=True)
private class RefreshRecordsProcessedBatchTest {
  	@IsTest
    private static void testSchedulable() {
        RefreshRecordsProcessedSchedule objSchedulable = null;
        
        objSchedulable = new RefreshRecordsProcessedSchedule();
        objSchedulable.execute(null);
    }
    
    @IsTest
    private static void testBatch() {
        RefreshRecordsProcessedBatch objBatch = null;
        Test.setMock(HttpCalloutMock.class, new RESTMock());
        objBatch = new RefreshRecordsProcessedBatch([SELECT ID FROM REPORT LIMIT 50]);
        Test.startTest();
        Database.executeBatch(objBatch,50);
        Test.stopTest();
    }
    
    private static void initializeTest() {
        Permission_Type__c objPermissionType = null;
        List<Permission_Type__c> lstPermissionType = null;
        
        lstPermissionType = new List<Permission_Type__c>();
        
        objPermissionType = new Permission_Type__c();
        objPermissionType.MaxRecords__c = 100;
        objPermissionType.Profile_Id__c = UserInfo.getProfileId();
        objPermissionType.Time__c = 'Semanal';
        lstPermissionType.add(objPermissionType);

        objPermissionType = new Permission_Type__c();
        objPermissionType.MaxRecords__c = 100;
        objPermissionType.UserId__c = UserInfo.getUserId();
        objPermissionType.Time__c = 'Semanal';
        lstPermissionType.add(objPermissionType);

		insert lstPermissionType;        
    }
}