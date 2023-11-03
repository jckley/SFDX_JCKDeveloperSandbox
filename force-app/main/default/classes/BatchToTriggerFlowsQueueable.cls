public class BatchToTriggerFlowsQueueable implements Queueable, Database.AllowsCallouts {
    BatchToTriggerFlowsHelper.BatchState batchState;

    public BatchToTriggerFlowsQueueable(BatchToTriggerFlowsHelper.BatchState batchState) {
        this.batchState = batchState;
    }

    public void execute(QueueableContext context) {
        BatchToTriggerFlows.batchFinishLogic(this.batchState);
    }

}