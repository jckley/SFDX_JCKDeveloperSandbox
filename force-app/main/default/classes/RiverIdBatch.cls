global class RiverIdBatch implements Database.Batchable<sObject>,Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, nro_socio__c, riverid_citizen__c, fecha_socio__c, cat_socio__c 
                                        FROM RiverId__c]);
    }
    global void execute(Database.BatchableContext BC, List<RiverId__c> scope){
        Map<Id,RiverId__c> riverIdRecord_ByRelatedContactId = new Map<Id,RiverId__c> ();

        for(RiverId__c thisRiverId : scope){
            riverIdRecord_ByRelatedContactId.put(thisRiverId.riverid_citizen__c,thisRiverId);
        }

        List<Contact> relatedContacts = [SELECT id,RiverId_Nro_socio__c,RiverId_fecha_socio__c,RiverId_cat_socio__c 
                                            FROM contact 
                                            WHERE id IN: riverIdRecord_ByRelatedContactId.keySet()];

        List<Contact> contactsToUpdate = new List<Contact> ();

        for(Contact thisContact : relatedContacts){
            RiverId__c riverIdRecord = riverIdRecord_ByRelatedContactId.get(thisContact.Id);
            
            Boolean updateThisContact = false;

            //if (riverIdRecord.nro_socio__c != thisContact.RiverId_Nro_socio__c) {
                thisContact.RiverId_Nro_socio__c = riverIdRecord.nro_socio__c.toplainstring();
                updateThisContact = true;
            //}
            if (riverIdRecord.fecha_socio__c != thisContact.RiverId_fecha_socio__c) {
                thisContact.RiverId_fecha_socio__c = riverIdRecord.fecha_socio__c;
                updateThisContact = true;
            }
            if (riverIdRecord.cat_socio__c != thisContact.RiverId_cat_socio__c) {
                thisContact.RiverId_cat_socio__c = riverIdRecord.cat_socio__c;
                updateThisContact = true;
                
            }
            if(updateThisContact){
                contactsToUpdate.add(thisContact);
            }
        }

        if (contactsToUpdate.size()>0) {
            Update contactsToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC) {
        //:D
    }
}