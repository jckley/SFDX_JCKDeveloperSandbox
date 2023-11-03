@isTest
public class BatchToTriggerFlowsQueueableTest {
    @isTest
    static void testQueueable() {
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

        Test.startTest();
        ID jobID = System.enqueueJob(new BatchToTriggerFlowsQueueable(batchState));
        Test.stopTest();

    }
}