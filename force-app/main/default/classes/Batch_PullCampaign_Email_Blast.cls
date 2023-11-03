global class Batch_PullCampaign_Email_Blast implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query = 'SELECT Id from Campaign';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Campaign> campList) 
    {
    	Typeform_pushpull tp = new Typeform_pushpull();
    	tp.parseEmailBlastDataForCampaign(campList[0]);
    }
    global void finish(Database.BatchableContext BC) {
    }
}