global inherited sharing class BatchCovid19UpdateNotifierUser implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Name FROM Covid19__c WHERE Notifier_User__c = null AND Notificacion_Date__c != null]);
    }
   
    global void execute(Database.BatchableContext BC, List<Covid19__c> scope){
    	
        Set<Id> covid19Ids = new Set<Id>();

        for(Covid19__c covid19 : scope){
            covid19Ids.add(covid19.Id);
        }

        Map<String, Covid19__History> mapHistory = new Map<String, Covid19__History>();

        for(Covid19__History history : [SELECT ParentId, NewValue, CreatedById FROM Covid19__History WHERE ParentId IN :covid19Ids AND Field = 'Notificacion_Date__c' ORDER BY CreatedDate DESC]){
            mapHistory.put(history.ParentId, history);
        }

        List<Covid19__c> covid19ToUpdate = new List<Covid19__c>();

        for(Covid19__c covid19 : scope){
            if(mapHistory.containsKey(covid19.Id)){
                covid19.Notifier_User__c = (Id)mapHistory.get(covid19.Id).CreatedById;
                covid19ToUpdate.add(covid19);
            }
        }

        if(!covid19ToUpdate.isEmpty()){
            update covid19ToUpdate;
        }

    }

    global void finish(Database.BatchableContext BC) {
    }
}