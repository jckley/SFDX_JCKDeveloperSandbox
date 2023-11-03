trigger EmpatiaTrigger on Empatia__c (before insert, after insert) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            EmpatiaTriggerHandler.handleBeforeInsert(Trigger.new);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            EmpatiaTriggerHandler.handleAfterInsert(Trigger.new);
        }
    }
}