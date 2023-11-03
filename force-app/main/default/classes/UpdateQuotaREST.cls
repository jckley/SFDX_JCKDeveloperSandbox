@RestResource(urlMapping='/quota/*')
global class UpdateQuotaREST {
    @HttpGet 
    global static String isAlive() {
        return 'isAlive!';
    }

       
    @HttpPost
    global static void updateQuota(String strUserId, Integer intProcessed) { 
        User objUser = null;
        System.debug('updateQuota [ strUserId : ' + strUserId + ' - intProcessed : ' + intProcessed + ' ] ->');

        objUser = [SELECT Id, Records_Processed__c 
                   FROM User 
                   WHERE Id =: UserInfo.getUserId()];
      
        if(objUser.Records_Processed__c == NULL) {
            objUser.Records_Processed__c = 0;
        }
        objUser.Records_Processed__c = objUser.Records_Processed__c  + intProcessed;
        update objUser;        
        
        System.debug('updateQuota [] <-');
    }
}