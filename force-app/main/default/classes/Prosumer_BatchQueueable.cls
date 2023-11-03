public class Prosumer_BatchQueueable implements Queueable, Database.AllowsCallouts {
    Prosumer_BatchHelper.BatchState batchState;
    Id retryedBatchOffsetInputId;

    public Prosumer_BatchQueueable(Prosumer_BatchHelper.BatchState batchState, Id retryedBatchOffsetInputId) {
        this.batchState = batchState;
        this.retryedBatchOffsetInputId = retryedBatchOffsetInputId;
    }

    public void execute(QueueableContext context) {
        Prosumer_BatchSharing.batchFinishLogic(this.batchState, this.retryedBatchOffsetInputId);
    }

}