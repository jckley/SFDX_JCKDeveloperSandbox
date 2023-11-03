trigger Export_Trigger on Export__c (before update, after update, after insert) {
    //ExportController.processApprovedExports(Trigger.new, Trigger.oldMap);
    //2020-01-08 FL Ajuste de circuito de trigger
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            ExportController.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            ExportController.afterInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            ExportController.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}