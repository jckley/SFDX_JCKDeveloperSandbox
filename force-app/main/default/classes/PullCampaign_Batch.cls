global class PullCampaign_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Id campid;
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query = 'SELECT Id from Campaign where id = \'' + campid + '\' LIMIT 1';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Campaign> camplist) 
    {
        Typeform_pushpull tp = new Typeform_pushpull();
        tp.pullcampaignMembers(campid);
    }

    global void finish(Database.BatchableContext BC) {
        Typeform_pushpull tp = new Typeform_pushpull();
        Boolean bMoreResult = tp.pullcampaignMembers(campid);
        if(bMoreResult){
            PullCampaign_Batch pb = new PullCampaign_Batch();
            pb.campid = campid;
            if(!test.isRunningTest())
                Database.executeBatch(pb,1);
        }
        else{
        	//send email
        	SendEmail.sendEmailonPullCampMembers();
        }
        
    }
    
}