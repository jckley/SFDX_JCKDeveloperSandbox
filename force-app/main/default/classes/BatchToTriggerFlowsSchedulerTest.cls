@isTest
public class BatchToTriggerFlowsSchedulerTest {
    @isTest
    static void testScheduler() {
        String configToUse = 'TEST';
        String mtdFieldToSwitch = 'Flow_by_batch_Flag__c';
        String mtdFromStatement = 'Contact';
        String mtdWhereStatement = 'LastName != \'excluido\'';
        Decimal mtdBatchSizeStatement = 100;
        Id lastRecordReferenceId = null;
    
        BatchToTriggerFlowsHelper.BatchState batchState = new BatchToTriggerFlowsHelper.BatchState(
          configToUse,
          mtdFieldToSwitch,
          mtdFromStatement,
          mtdWhereStatement,
          mtdBatchSizeStatement, 
          lastRecordReferenceId
        );

        batchState.retriedTimes = 1;

        BatchToTriggerFlowsScheduler scheduledJob = new BatchToTriggerFlowsScheduler(batchState);
        Datetime sysTime = System.now().addSeconds(60);
        String chron = BatchToTriggerFlowsHelper.makeChronFromDateTime(sysTime);
        String name = 'RetriedTimes' + batchState.retriedTimes + ' - ' + chron;

        Test.startTest();
        String scheduledJobId = System.schedule(name, chron, scheduledJob);
        Test.stopTest();
    }
}