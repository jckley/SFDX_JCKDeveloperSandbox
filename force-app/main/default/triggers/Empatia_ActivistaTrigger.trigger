trigger Empatia_ActivistaTrigger on Empatia_Activista__c (before insert, before update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            Empatia_ActivistaTriggerHandler.handleBeforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            Empatia_ActivistaTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}