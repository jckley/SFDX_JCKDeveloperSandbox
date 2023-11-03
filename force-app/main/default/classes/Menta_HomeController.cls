public class Menta_HomeController {

    public Menta_HomeController () {
        
    }
    
    @AuraEnabled
    public static TerritoryWrapper2 getTerritoryById(Id territoryId) {
        System.debug('ayy : ' + territoryId);
        return TerritoryDetailController.getTerritoryById2(territoryId);
    }

}