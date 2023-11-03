public class TerritoryFullPageController_lt {
  @AuraEnabled(Cacheable=true)
  public static List<Territorio_Administrativo__c> getTerritoryById(Id territoryId) {
    List<Territorio_Administrativo__c> terrList = [
        SELECT
          Id, Name,
          Nivel_Administrativo__c,
          ParentId__c,
          ParentId__r.Name,
          ParentId__r.ParentId__c,
          ParentId__r.ParentId__r.Name,
          ParentId__r.ParentId__r.ParentId__c,
          ParentId__r.ParentId__r.ParentId__r.Name,
          ParentId__r.ParentId__r.ParentId__r.ParentId__c,
          ParentId__r.ParentId__r.ParentId__r.ParentId__r.Name,
          (SELECT Id, Name FROM ChildTerritories__r)
        FROM Territorio_Administrativo__c
        WHERE id = :territoryId
      ];
      
    return terrList;
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
      log.Territory__c = recordId;
      log.logSource__c = logSource;
      Insert log;
  }
}