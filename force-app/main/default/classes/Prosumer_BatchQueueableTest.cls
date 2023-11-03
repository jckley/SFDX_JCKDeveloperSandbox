@isTest
public class Prosumer_BatchQueueableTest {
    @isTest
    static void testScheduler() {
        String accProsumerId = 'ASD123';
        String accSharingCriteria = 'LastName != \'excluido\'';
        Id accRecordId = null;
        Id lastRecordReferenceId = null;
    
        Prosumer_BatchHelper.BatchState batchState = new Prosumer_BatchHelper.BatchState(accRecordId, accSharingCriteria, accProsumerId, lastRecordReferenceId);

        Id retryedBatchOffsetInputId  = null;

        batchState.retriedTimes = 1;

        Test.startTest();
        ID jobID = System.enqueueJob(new Prosumer_BatchQueueable(batchState, retryedBatchOffsetInputId));
        Test.stopTest();
    }
}