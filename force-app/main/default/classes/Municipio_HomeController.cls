public class Municipio_HomeController {    
    @AuraEnabled
    public static TerritoryWrapper2 getRootTerritory() {
        RemotingMessageHelper.Territory objTerritory = null;
        
        objTerritory =  TerritoryHierarchyController.retrieveParentTerritory();
        
        System.debug('objTerritory : ' + objTerritory);
        return  TerritoryDetailController.getTerritoryById2(objTerritory.Id);
    }
}