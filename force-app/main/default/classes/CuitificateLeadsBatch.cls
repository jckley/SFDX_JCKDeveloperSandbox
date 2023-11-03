global class CuitificateLeadsBatch implements Database.Batchable<sObject> {   
    global Database.QueryLocator start(Database.BatchableContext objBatchableContext) {
        Database.QueryLocator objQueryLocator = null;
        
        System.debug('start [ objBatchableContext : ' + objBatchableContext + '] ->');    
        
        objQueryLocator = Database.getQueryLocator('SELECT ID, Email, FirstName, LastName, Birthdate__c FROM Lead WHERE RecordType.DeveloperName = \'PulsoCRM\'');            
        
        System.debug('start [' + objQueryLocator + '] <-');   
        return objQueryLocator;
    }
    
    global void execute(Database.BatchableContext objBatchableContext, List<Lead> lstLeads) {                
        List<Contact> lstContacts = null;
        Contact objContact = null;
        
        System.debug('execute [ objBatchableContext : ' + objBatchableContext + ' : lstLeads : ' + lstLeads + '] ->');  
		lstContacts = new List<Contact>();
        for(Lead objLead : lstLeads) {
            CUITificadorHelper.cuitificateLead(objLead);
        }
                
        System.debug('execute [] <-');  
    }  
    
    global void finish(Database.BatchableContext objBatchableContext) {
        System.debug('finish [] ->');  
                     
        System.debug('finish [] <-');  
    }
    
}