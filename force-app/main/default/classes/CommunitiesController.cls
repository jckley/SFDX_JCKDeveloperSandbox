public without sharing class CommunitiesController {
    
    @AuraEnabled(cacheable=true)
    public static CitizenWrapper retrieveInfoFromCitizenId(Id contactId) {
        System.debug(LoggingLevel.WARN, 'CommunitiesController.retrieveInfoFromCitizenId [ contactId : ' + contactId + '] ->');
        return ContactDetailController.retrieveInfoFromCitizenId(contactId); 
    }

    @AuraEnabled(cacheable=true)
    public static String retrieveSite() {
        System.debug(LoggingLevel.WARN, 'CommunitiesController.retrieveSite()');

        HelperFunctions.CommunitySite communitySite = HelperFunctions.retrieveSite();
        return communitySite != null ? communitySite.name() : HelperFunctions.CommunitySite.SALESFORCE.name(); 
    }
    
    @AuraEnabled(cacheable=true)
    public static TerritoryWrapper2 getRootTerritory(String territoryName) {
        //los lwc llaman a este pasandole null
        RemotingMessageHelper.Territory objTerritory = null;
        
        objTerritory =  TerritoryHierarchyController.retrieveParentTerritory(territoryName);
        
        System.debug('objTerritory : ' + objTerritory);
        return  TerritoryDetailController.getTerritoryById2(objTerritory.Id);
    }

    @AuraEnabled(cacheable=true)
    public static TerritoryWrapper2 getRootTerritory() {
        //se crea metodo sobrecargado por seguridad y para los test
        return  getRootTerritory(null);
    }

    @AuraEnabled
    public static void createLog (Id recordId) {
        String networkId = Network.getNetworkId();
        String logSource = 'CRM';
        if (String.isNotBlank(networkId)) {
            //no se pueden crear datos de test para el objeto NETWORK, porque reprensenta comunidades. Asi que lo testeo.
            //una alternativa seria que el lwc le pase como parametro el context (nompre de la app del CRM o de la comunidad donde se este usando)
            List<Network> lstNetwork = [SELECT NAME FROM NETWORK WHERE ID =: networkId];
            logSource = lstNetwork[0].name;
        }
    
        ActivityLog__c log = new ActivityLog__c ();
        log.Citizen__c = recordId;
        log.logSource__c = logSource;
        Insert log;
    }

}