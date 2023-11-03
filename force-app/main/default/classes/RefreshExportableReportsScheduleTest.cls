@IsTest(SeeAllData=True)
private  class RefreshExportableReportsScheduleTest {
	@IsTest
    private static void testRefreshExportableReports() {
        RefreshExportableReportsSchedule objSchedulable = null;
       
        objSchedulable = new RefreshExportableReportsSchedule();
        Test.startTest();
        objSchedulable.execute(null);
        Test.stopTest();
    }
}