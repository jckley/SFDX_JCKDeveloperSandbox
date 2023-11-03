global class PullTypeform_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global String formid;
    global Campaign camp;
    global String campid;
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query = 'SELECT Id, Type_Form_ID__c from Campaign where Id = \'' + campid + '\' LIMIT 1';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Campaign> camplist) 
    {
        Typeform_pushpull tp = new Typeform_pushpull();
        tp.pulldata(formid, camp);
    }

    global void finish(Database.BatchableContext BC) {
        Typeform_pushpull tp = new Typeform_pushpull();
        Boolean bMoreResult = tp.pulldata(formid, camp);
        if(bMoreResult){
            PullTypeform_Batch pb = new PullTypeform_Batch();
            pb.formid = formid;
            pb.campid = camp.id; pb.camp = camp;
            if(!test.isRunningTest())
            	Database.executeBatch(pb,1);
        }
        
    }

}