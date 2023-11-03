public with sharing class CommunitiesChileController {
    
    @AuraEnabled(cacheable=true)
    public static CitizenWrapper retrieveInfoFromCitizenId(Id contactId) {
        System.debug(LoggingLevel.WARN, 'CommunitiesChileController.retrieveInfoFromCitizenId [ contactId : ' + contactId + '] ->');
        return ContactDetailController.retrieveInfoFromCitizenId(contactId); 
    }

    @AuraEnabled(cacheable=true)
    public static String retrieveSite() {
        System.debug(LoggingLevel.WARN, 'CommunitiesChileController.retrieveSite()');

        HelperFunctions.CommunitySite communitySite = HelperFunctions.retrieveSite();
        return communitySite != null ? communitySite.name() : HelperFunctions.CommunitySite.SALESFORCE.name(); 
    }
    
    @AuraEnabled(cacheable=true)
    public static TerritoryWrapper2 getRootTerritory() {
        RemotingMessageHelper.Territory objTerritory = null;
        
        objTerritory =  TerritoryHierarchyChileController.retrieveParentTerritory();
        
        System.debug('objTerritory : ' + objTerritory);
        return  TerritoryDetailChileController.getTerritoryById2(objTerritory.Id);
    }

}