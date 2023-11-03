public with sharing class Pilar360Controller {
    
    @AuraEnabled(cacheable=true)
    public static List<PilarCitizenInteractions__c> retrieveInteractions(String id) {
        return [SELECT Id, Name, PilarCiudadanoID__c, Interaction_Date__c, Programs__c, Services__c FROM PilarCitizenInteractions__c WHERE PilarCitizenInteractions__c.Pilar360Citizen_SFID__R.Citizen__c =: id ];
    }

    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> retrieveStats(String id) {
        return [SELECT Programs__c, Services__c, COUNT(id) FROM PilarCitizenInteractions__c WHERE PilarCitizenInteractions__c.Pilar360Citizen_SFID__R.Citizen__c =: id GROUP BY Programs__c, Services__c ];
    }

    @AuraEnabled(cacheable=true)
    public static Pilar360__c retrievePilarRecord(String id) {
        List<Pilar360__c> objLst = [SELECT Citizen__R.Name FROM Pilar360__c WHERE Citizen__c =: id];
        if (!objLst.isEmpty())
            return objLst[0];
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> retrievePrograms() {
        return HelperFunctions.retrievePicklistValuesToStringList('PilarCitizenInteractions__c', 'Programs__c');
    }
}