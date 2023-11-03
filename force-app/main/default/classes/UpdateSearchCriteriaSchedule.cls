global class UpdateSearchCriteriaSchedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        // Implement any logic to be scheduled
       
        // We now call the batch class to be scheduled
        UpdateSearchCriteriaBatch b = new UpdateSearchCriteriaBatch ();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        Database.executebatch(b,10000);
    }

}