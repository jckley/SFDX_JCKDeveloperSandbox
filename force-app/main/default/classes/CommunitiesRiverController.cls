public with sharing class CommunitiesRiverController {
    
    @AuraEnabled(cacheable=true)
    public static List<RiverId_Polls__c> retrieveInfoPollsFromCitizenId(Id contactId) {
        try {
            RiverId__c river_id = [SELECT Id FROM RiverId__c WHERE riverid_citizen__c =: contactId LIMIT 1];
            if (river_id != null) {
                List<RiverId_Polls__c> polls = [SELECT Abonos__c, Beneficios__c, Estadio__c, Futbol__c, Instalaciones__c, Fecha_Respuesta__c FROM RiverId_Polls__c WHERE RiverId_SFID__c =: river_id.Id];
                return polls;
            }
        } catch (System.QueryException e) {
            system.debug('===error===>'+e);
            return null;
        }

        return null;
    }
}