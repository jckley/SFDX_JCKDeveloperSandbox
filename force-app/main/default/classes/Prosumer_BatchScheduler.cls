public class Prosumer_BatchScheduler implements Schedulable {
    Prosumer_BatchHelper.BatchState batchState;
    Id retryedBatchOffsetInputId;

    public Prosumer_BatchScheduler (Prosumer_BatchHelper.BatchState batchState, Id retryedBatchOffsetInputId) {
     this.batchState = batchState;
     this.retryedBatchOffsetInputId = retryedBatchOffsetInputId;
    }
 
    public void execute(SchedulableContext sc) {
      //tengo que pasar por un encolable porque no se pueden hacer api calls directamente desde aca
      //asi que abria que usar, o un encolable
      //o un @future, pero ese no se si me dejar despues mandar el batch (caso que salga bien), u otro scheduleable (caso que salga mal)
      ID jobID = System.enqueueJob(new Prosumer_BatchQueueable(this.batchState, this.retryedBatchOffsetInputId));
    }
}