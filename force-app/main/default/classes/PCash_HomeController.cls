public class PCash_HomeController {
    
    public PCash_HomeController () {
        
    }
    
    @AuraEnabled
    public static TerritoryWrapper2 getTerritoryById(Id territoryId) {
        String terId = [SELECT Id FROM Territorio_Administrativo__c WHERE Name = 'Argentina'].Id;
        return TerritoryDetailController.getTerritoryById2(terId);
    }
}