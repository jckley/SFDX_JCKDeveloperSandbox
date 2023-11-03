@IsTest
private class UpdateQuotaRESTTest {
    @IsTest
    private static void testUpdateQuota() {
        User objUser = null;
        
     	System.assertEquals('isAlive!', UpdateQuotaREST.isAlive());
        
        objUser = [SELECT Id, Records_Processed__c 
                   FROM User 
                   WHERE Id =: UserInfo.getUserId()];
      
        objUser.Records_Processed__c = 100;
        update objUser;
        
        UpdateQuotaREST.updateQuota(UserInfo.getUserId(), 50);
        System.assertEquals(150, [SELECT Id, Records_Processed__c FROM User WHERE Id =: UserInfo.getUserId()].Records_Processed__c);        
    }
}