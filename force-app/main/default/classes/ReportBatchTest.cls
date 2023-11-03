@IsTest(SeeAllData=true)
private class ReportBatchTest {
	@isTest
    private static void reportBatchTest() {
     	RefreshRecordsProcessedSchedule objRefresh = null;
        
        objRefresh = new RefreshRecordsProcessedSchedule();
        objRefresh.execute(null);
    }
}