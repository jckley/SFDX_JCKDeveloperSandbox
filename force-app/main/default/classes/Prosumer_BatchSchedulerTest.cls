@isTest
public class Prosumer_BatchSchedulerTest {
    @isTest
    static void testScheduler() {
        String accProsumerId = 'ASD123';
        String accSharingCriteria = 'LastName != \'excluido\'';
        Id accRecordId = null;
        Id lastRecordReferenceId = null;
    
        Prosumer_BatchHelper.BatchState batchState = new Prosumer_BatchHelper.BatchState(accRecordId, accSharingCriteria, accProsumerId, lastRecordReferenceId);

        Id retryedBatchOffsetInputId  = null;

        batchState.retriedTimes = 1;

        Prosumer_BatchScheduler scheduledJob = new Prosumer_BatchScheduler(batchState, retryedBatchOffsetInputId);
        Datetime sysTime = System.now().addSeconds(60);
        String chron = BatchToTriggerFlowsHelper.makeChronFromDateTime(sysTime);
        String name = 'RetriedTimes' + batchState.retriedTimes + ' - ' + chron;

        Test.startTest();
        String scheduledJobId = System.schedule(name, chron, scheduledJob);
        Test.stopTest();
    }
}