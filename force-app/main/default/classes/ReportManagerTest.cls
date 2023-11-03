@IsTest(SeeAllData=true)
private	class ReportManagerTest {    
    @IsTest(SeeAllData=true)
    private static void retrieveReportMetadataTest() {
        Report objReport = null; 
        RemotingMessageHelper.PermissionRequest objPermissionRequest = null;
        ReportManager.elmejortestlohacelusuarioenproduccion();
        
        objReport = [SELECT Id FROM Report LIMIT 1];
        
        //ReportManager.retrieveReportMetadata(objReport.Id);
        ReportManager.listUserProfile();
        ReportManager.retrieveTimeRange();
        ReportManager.retrievePermissions(UserInfo.getUserId(), NULL ,'Contact');
        ReportManager.retrievePermissions(NULL, UserInfo.getProfileId() ,'Contact');
        //ReportManager.exportReport(objReport.Id);
        
        objPermissionRequest = new RemotingMessageHelper.PermissionRequest();
        objPermissionRequest.MaxRecords = '500';
        objPermissionRequest.ProfileId = UserInfo.getProfileId();
        objPermissionRequest.RecordsQuota = '100';
        objPermissionRequest.SObjectName = 'Contact';
        objPermissionRequest.TimeRange = 'Mensual';
        objPermissionRequest.UserId = UserInfo.getUserId();
        
        ReportManager.updatePermissions(JSON.serialize(objPermissionRequest));
        
        User objUser = [SELECT Records_Processed__c 
                        FROM User 
                        WHERE Id =: UserInfo.getUserId()];
        objUser.Records_Processed__c = 0;
        update objUser;
        
        //ReportManager.retrieveReportMetadata(objReport.Id);
        ReportManager.listUserProfile();
        ReportManager.retrieveTimeRange();
        ReportManager.retrievePermissions(UserInfo.getUserId(), NULL ,'Contact');
        ReportManager.retrievePermissions(NULL, UserInfo.getProfileId() ,'Contact');
        //ReportManager.exportReport(objReport.Id);
        
        //TODO: ACA DEBERIA HABER ALGUN ASSERT.
    }
}