trigger PRM_Cuidarnos_Covid19 on Covid19__c (after update) {
   /*for(Covid19__c objCovid : Trigger.New){        
        if(objCovid.Cuidarnos_Comunidad_Status__c == 'Confirmado' && objCovid.Cuidarnos_Comunidad_Status__c != Trigger.oldMap.get(objCovid.Id).Cuidarnos_Comunidad_Status__c) {        
            PRM_Cuidarnos.marcarCiudadanoInSalesforce(objCovid.citizen__c, false);
        } 
    }  */ 

    System.debug('PRM_Cuidarnos_Covid19 [] ->');
    
    if(Trigger.IsUpdate) {
        if(Trigger.isAfter) {
            PRM_Cuidarnos.notifyUserInvalidResultSMSController(Trigger.new, Trigger.oldMap);
        }
    }

    System.debug('PRM_Cuidarnos_Covid19 [] <-');
}