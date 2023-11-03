global class Schedule_PullCampaign_Email_Blast implements Schedulable{
    global void execute(SchedulableContext ctx) {
    	Batch_PullCampaign_Email_Blast pc = new Batch_PullCampaign_Email_Blast();
    	database.executeBatch(pc, 1); //run one campaign at a time
   }
    
}