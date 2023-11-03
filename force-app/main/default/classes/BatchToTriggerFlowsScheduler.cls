public class BatchToTriggerFlowsScheduler implements Schedulable {
    BatchToTriggerFlowsHelper.BatchState batchState;

    public BatchToTriggerFlowsScheduler (BatchToTriggerFlowsHelper.BatchState batchState) {
     this.batchState = batchState;
    }
 
    public void execute(SchedulableContext sc) {
      //tengo que pasar por un encolable porque no se pueden hacer api calls directamente desde aca
      //asi que abria que usar, o un encolable
      //o un @future, pero ese no se si me dejar despues mandar el batch (caso que salga bien), u otro scheduleable (caso que salga mal)
      ID jobID = System.enqueueJob(new BatchToTriggerFlowsQueueable(batchState));
    }
}