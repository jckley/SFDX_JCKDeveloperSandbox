public without sharing class CountrySelectorController {
    @AuraEnabled
    public static List<RemotingMessageHelper.Territory> retrieveTerritories() {
    	User objUser = NULL;    
        List<Territorio_Administrativo__c> lstTerritoriesC = null;
        List<RemotingMessageHelper.Territory> lstTerritories = null;
        RemotingMessageHelper.Territory objTerritory = null;
        
        System.debug('retrieveTerritories [] ->');
        try {                    
            lstTerritories = new List<RemotingMessageHelper.Territory>();
            
            objUser = [SELECT UserRole.DeveloperName
                       FROM User 
                       WHERE Id =: UserInfo.getUserId()]; 
            
            
            lstTerritoriesC = [SELECT Id, Name, Flag__c, Nivel_Administrativo__c, DeveloperName__c
                               FROM Territorio_Administrativo__c
                               WHERE IsRole__c = TRUE
                               ORDER BY Level0Name__c, Level1Name__c, Level2Name__c, Level3Name__c, Nivel_Administrativo__c];
            
            for(Territorio_Administrativo__c objTerritoryC : lstTerritoriesC) {
                objTerritory = new RemotingMessageHelper.Territory(objTerritoryC, (objUser.UserRole.DeveloperName == objTerritoryC.DeveloperName__c));
                
                lstTerritories.add(objTerritory);
            }
            
            Reports.ReportManager.runReport('00O6A000005duRoUAI', true);
        } catch (Exception Ex) {
            System.debug('retrieveTerritories [Ex : ' + Ex + ']');
        }
        System.debug('retrieveTerritories [' + lstTerritories + '] <-');
        
        return lstTerritories;
    } 
    
	@AuraEnabled
    public static Boolean changeTerritory(String strTerritory) {
    	User objUser = NULL;    
        UserRole objUserRole = NULL;    
        Boolean boolResult = false;
        
        System.debug('changeTerritory [strTerritory : ' + strTerritory + '] ->');
                   
        objUserRole = [SELECT Id 
                       FROM UserRole 
                       WHERE DeveloperName =: strTerritory];
        
        objUser = [SELECT UserRoleId 
                   FROM User 
                   WHERE Id =: UserInfo.getUserId()];    
        
        
        objUser.UserRoleId = objUserRole.Id;            
        update objUser;
        
        boolResult = true;
        //Reports.ReportManager.runReport('00O0n000000K1QVEA0', true);
        
        System.debug('changeTerritory [] <-');
        
        return boolResult;
    } 
}