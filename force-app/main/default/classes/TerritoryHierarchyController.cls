/**
* ClassName: TerritoryHierarchyController
* Description: Controller class for the territory hierarchy view
* Developer: Luis Puentes - Date: 12/07/2018
*/
global with sharing class TerritoryHierarchyController {
    
    public Territorio_Administrativo__c mainTerritory {get; set;}
    public String territoryId {get; set;}
    public Integer adminLevel {get; set;}
    public List<Territorio_Administrativo__c> level1territories {get; set;}
    public List<Territorio_Administrativo__c> level2territories {get; set;}
    public List<Territorio_Administrativo__c> level3territories {get; set;}
    public List<Territorio_Administrativo__c> level4territories {get; set;}
    public String territory1selected {get; set;}
    public String territory2selected {get; set;}
    public String territory3selected {get; set;}
    public String territory4selected {get; set;}
    
    
    public TerritoryHierarchyController(){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.Territory');
        Decimal userRoleLevel = sessionPart.contains('UserRoleLevel') ? (Decimal)sessionPart.get('UserRoleLevel') : NULL;
        territoryId = apexpages.currentpage().getparameters().get('id');
        adminLevel = apexpages.currentpage().getparameters().get('al') != NULL ? Integer.valueOf(apexpages.currentpage().getparameters().get('al')) : 0;
        
        if(sessionPart.get('ComesFrom') == 'URL' && userRoleLevel != NULL && sessionPart.contains('SelTer' + (userRoleLevel + 1)) && territoryId != NULL && adminLevel != 0){
            territory1selected = (String)sessionPart.get('SelTer' + (userRoleLevel + 1));
            mainTerritory = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c FROM Territorio_Administrativo__c WHERE Id =: territory1selected];
            level1territories = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c FROM Territorio_Administrativo__c WHERE ParentId__c =: mainTerritory.ParentId__c ORDER BY Name];
            level2territories = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c FROM Territorio_Administrativo__c WHERE ParentId__c =: territory1selected ORDER BY Name];
            territory2selected = (sessionPart.contains('SelTer' + (userRoleLevel + 2)) && territory1selected == sessionPart.get('SelTer' + (userRoleLevel + 2) + 'Parent')) ? (String)sessionPart.get('SelTer' + (userRoleLevel + 2)) : NULL;
            territory3selected = (sessionPart.contains('SelTer' + (userRoleLevel + 3)) && territory2selected == sessionPart.get('SelTer' + (userRoleLevel + 3) + 'Parent')) ? (String)sessionPart.get('SelTer' + (userRoleLevel + 3)) : NULL;
            territory4selected = (sessionPart.contains('SelTer' + (userRoleLevel + 4)) && territory3selected == sessionPart.get('SelTer' + (userRoleLevel + 4) + 'Parent')) ? (String)sessionPart.get('SelTer' + (userRoleLevel + 4)) : NULL;
            level3territories = (territory2selected != NULL) ? [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c FROM Territorio_Administrativo__c WHERE ParentId__c =: territory2selected ORDER BY Name] : NULL;
            level4territories = (territory3selected != NULL) ? [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c FROM Territorio_Administrativo__c WHERE ParentId__c =: territory3selected ORDER BY Name] : NULL;
        }else if(sessionPart.get('ComesFrom') == 'Standard' && territoryId != NULL && adminLevel != 0){
            mainTerritory = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c, ParentId__r.ParentId__c, ParentId__r.ParentId__r.ParentId__c, ParentId__r.ParentId__r.ParentId__r.ParentId__c 
                             FROM Territorio_Administrativo__c 
                             WHERE Id =: territoryId];
            if(adminLevel == 1){
                level2territories = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                                     FROM Territorio_Administrativo__c 
                                     WHERE ParentId__c =: mainTerritory.Id];
                level1territories = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                                     FROM Territorio_Administrativo__c 
                                     WHERE ParentId__c =: mainTerritory.ParentId__c];
                territory1selected = mainTerritory.Id;
            }else if(adminLevel == 2){
                level3territories = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                                     FROM Territorio_Administrativo__c 
                                     WHERE ParentId__c =: mainTerritory.Id];
                level2territories = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                                     FROM Territorio_Administrativo__c
                                     WHERE ParentId__c =: mainTerritory.ParentId__c];
                level1territories = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                                     FROM Territorio_Administrativo__c 
                                     WHERE ParentId__c =: mainTerritory.ParentId__r.ParentId__c];
                territory2selected = mainTerritory.Id;
                territory1selected = mainTerritory.ParentId__c;
            }else if(adminLevel == 3){
                level4territories = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                                     FROM Territorio_Administrativo__c 
                                     WHERE ParentId__c =: mainTerritory.Id];
                level3territories = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                                     FROM Territorio_Administrativo__c 
                                     WHERE ParentId__c =: mainTerritory.ParentId__c];
                level2territories = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                                     FROM Territorio_Administrativo__c
                                     WHERE ParentId__c =: mainTerritory.ParentId__r.ParentId__c];
                level1territories = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                                     FROM Territorio_Administrativo__c 
                                     WHERE ParentId__c =: mainTerritory.ParentId__r.ParentId__r.ParentId__c];
                territory3selected = mainTerritory.Id;
                territory2selected = mainTerritory.ParentId__c;
                territory1selected = mainTerritory.ParentId__r.ParentId__c;
            }else if(adminLevel == 4){
                level4territories = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                                     FROM Territorio_Administrativo__c 
                                     WHERE ParentId__c =: mainTerritory.ParentId__c];
                level3territories = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                                     FROM Territorio_Administrativo__c 
                                     WHERE ParentId__c =: mainTerritory.ParentId__r.ParentId__c];
                level2territories = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                                     FROM Territorio_Administrativo__c
                                     WHERE ParentId__c =: mainTerritory.ParentId__r.ParentId__r.ParentId__c];
                level1territories = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                                     FROM Territorio_Administrativo__c 
                                     WHERE ParentId__c =: mainTerritory.ParentId__r.ParentId__r.ParentId__r.ParentId__c];
                territory4selected = mainTerritory.Id;
                territory3selected = mainTerritory.ParentId__c;
                territory2selected = mainTerritory.ParentId__r.ParentId__c;
                territory1selected = mainTerritory.ParentId__r.ParentId__r.ParentId__c;
            }
        } else {
            String userRoleId = UserInfo.getUserRoleId();
            removeSessionData();

            UserRole userRole = [SELECT Id, Name, DeveloperName, ParentRoleId FROM UserRole WHERE Id =: userRoleId];
            String parentRoleName = userRole.DeveloperName.replace('_', ' ');
            Integer intLevel =  getRoleAdministrativeLevel(parentRoleName, 0);
            
            System.debug('parentRoleName : ' + parentRoleName);
            System.debug('intLevel : ' + intLevel);

            level1territories = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                                 FROM Territorio_Administrativo__c 
                                 //WHERE ParentId__c =: mainTerritory.Id
                                 WHERE Nivel_Administrativo__c = :intLevel
                                 AND ParentId__r.Name = :parentRoleName.replace('_', ' ')
                                 ORDER BY Name];   
            mainTerritory = level1territories[0];
        }
        mainTerritory = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                         FROM Territorio_Administrativo__c 
                         WHERE Id =: level1territories[0].ParentId__c];
    }
    
    private Integer getRoleAdministrativeLevel(String strParent, Integer intLevel) {
        Integer intRootLevel = null;
        List<Territorio_Administrativo__c> lstTerritories = null;

        System.debug('getRoleAdministrativeLevel [strRol : ' + strParent + ' - intLevel : ' + intLevel + '] ->');

        lstTerritories = [  SELECT Id 
                            FROM Territorio_Administrativo__c 
                            WHERE  Nivel_Administrativo__c = : intLevel 
                            AND ParentId__r.Name = : strParent];
        if(lstTerritories.size() == 0 && intLevel < 5) {
            intRootLevel = getRoleAdministrativeLevel(strParent, intLevel + 1);
        } else {
            intRootLevel = intLevel;
        }

        System.debug('getRoleAdministrativeLevel [' + intRootLevel + '] <-');
        return intRootLevel;
    }
    webservice static String getChildTerritories(String territoryId, String parentId) {
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.Territory');
        Decimal territoryLevel;
        List<Territorio_Administrativo__c> territories =  [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c FROM Territorio_Administrativo__c WHERE ParentId__c =: territoryId ORDER BY Name];
        territoryLevel = territories.size() != 0 ? (territories[0].Nivel_Administrativo__c - 1) : [SELECT Id, Nivel_Administrativo__c FROM Territorio_Administrativo__c WHERE Id =: territoryId].Nivel_Administrativo__c;
        sessionPart.put('SelTer' + territoryLevel, territoryId);
        sessionPart.put('SelTer' + territoryLevel + 'Parent', parentId);
        return JSON.serialize(territories);
    }
    
    webservice static void saveSelectedTerritory(String territoryId, String parentId, Decimal territoryLevel) {
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.Territory');
        sessionPart.put('SelTer' + territoryLevel, territoryId);
        sessionPart.put('SelTer' + territoryLevel + 'Parent', parentId);
    }
    
    public void removeSessionData(){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.Territory');
        sessionPart.remove('SelTer1');
        sessionPart.remove('SelTer2');
        sessionPart.remove('SelTer3');
        sessionPart.remove('SelTer4');
        sessionPart.remove('SelTer1Parent');
        sessionPart.remove('SelTer2Parent');
        sessionPart.remove('SelTer3Parent');
        sessionPart.remove('SelTer4Parent');
    }
    
    public PageReference redirect() {
        String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        territoryId = apexpages.currentpage().getparameters().get('id');
        adminLevel = apexpages.currentpage().getparameters().get('al') != NULL ? Integer.valueOf(apexpages.currentpage().getparameters().get('al')) : 0;
        
        if(userAgent.contains('Mobi')) {
            PageReference pr = Page.TerritoryHierarchyMobile;
            pr.getParameters().put('id',territoryId);
            pr.getParameters().put('al',adminLevel + '');
            pr.setRedirect(true);
            return pr;
        }
        return null;
    }
    
    @AuraEnabled
    public static RemotingMessageHelper.Territory retrieveParentTerritory() {
        //metodo original, llamamos al sobrecargado pasandole null, que se va a comportar como antes. 
        return retrieveParentTerritory(null);
    }

    @AuraEnabled
    public static RemotingMessageHelper.Territory retrieveParentTerritory(String territoryName) { 
        RemotingMessageHelper.Territory objTerritory = null;
        Community_Config__mdt objSetting = null;
        List<Territorio_Administrativo__c> lstTerritoriesC = null;      
        String strLevel = null;
        Integer intLevel = null;
         
        System.debug('retrieveParentTerritory [] ->');

        if (territoryName == null) {
            //caso default, elementos que usen el metodo viejo o que llamen desde una comunidad.
            objSetting = HelperFunctions.retrieveCommunitySettings();
        
            if(objSetting != NULL) {
                strLevel = objSetting.RootTerritory__c;
                intLevel = Integer.valueOf(objSetting.Root_Admin_Level__c);
            }  else {
                strLevel = 'Argentina';
                intLevel = 0;
            }
        } else {
            //nueva logia para permitir parametros desde la pagina lighting
            strLevel = territoryName;
            intLevel = 0;
        }
        lstTerritoriesC = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                           FROM Territorio_Administrativo__c 
                           WHERE Nivel_Administrativo__c =: intLevel
                           AND Name =:strLevel 
                           ORDER BY Name
                           LIMIT 1];
        if(!lstTerritoriesC.isEmpty()) {
            objTerritory  = new RemotingMessageHelper.Territory(lstTerritoriesC[0]);	            
        }
        
        System.debug('retrieveParentTerritory [' + objTerritory + '] <-');
        
        return objTerritory;
    }
    
    @AuraEnabled
    public static List<RemotingMessageHelper.Territory> retrieveTerritoriesByParent(Id strParentId) {
        List<Territorio_Administrativo__c> lstTerritoriesC = null;
        List<RemotingMessageHelper.Territory> lstTerritories = null;
        RemotingMessageHelper.Territory objTerritory = null;
        String strUserRoleName = null;
        Id objSelectedTerritoryId = null;
        Cache.SessionPartition objSessionPartition = null;
        Set<Id> setParentTerritoriesIds = null;
        
        System.debug('retrieveTerritoriesByParent [ strParentId : ' + strParentId + '] ->');
        objSessionPartition = Cache.Session.getPartition('local.Territory');
        
        //strUserRoleName = retrieveUserRoleName();
        
        //if(String.isNotBlank(strUserRoleName)) {
        if(String.isNotBlank(strParentId)) {
            lstTerritoriesC = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                               FROM Territorio_Administrativo__c 
                               WHERE ParentId__c =: strParentId
                               ORDER BY Name];                      
        } else {
            lstTerritoriesC =  [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                                FROM Territorio_Administrativo__c 
                                WHERE Nivel_Administrativo__c = 1
                                ORDER BY Name
                                LIMIT 1];  
        }
        
        System.debug('Selected Territory : ' + objSessionPartition.get('SelectedTerritory'));
        objSelectedTerritoryId = (objSessionPartition.get('SelectedTerritory') == NULL || objSessionPartition.get('SelectedTerritory') == '')?NULL:(Id)objSessionPartition.get('SelectedTerritory');
        if(objSelectedTerritoryId != NULL) {
            setParentTerritoriesIds = retrieveTerritoriesBySelectedChild(objSelectedTerritoryId);
        }
        
        lstTerritories = new List<RemotingMessageHelper.Territory>();
        for(Territorio_Administrativo__c objTerritoryC : lstTerritoriesC) {
            objTerritory = new RemotingMessageHelper.Territory(objTerritoryC);
            objTerritory.IsSelected = (setParentTerritoriesIds == NULL)?false:setParentTerritoriesIds.contains(objTerritoryC.Id);
            lstTerritories.add(objTerritory);
        }             
        //}
        System.debug('retrieveTerritoriesByParent [ ' + lstTerritoriesC + '] <-');
        
        return lstTerritories;
    }
    
    @AuraEnabled
    public static void saveLastSelectedTerritory(Id strTerritoryId) {  
        Set<Id> setParentTerritoriesIds = null;
        Cache.SessionPartition objSessionPartition = null;
        
        System.debug('saveLastSelectedTerritory [ strTerritoryId : ' + strTerritoryId + '] ->');
        
        objSessionPartition = Cache.Session.getPartition('local.Territory');
        objSessionPartition.put('SelectedTerritory', strTerritoryId);
        
        System.debug('retrieveTerritoriesByParent [] <-');
    }
    
    @AuraEnabled
    public static void clearLastSelectedTerritory() {  
        Cache.SessionPartition objSessionPartition = null;
        
        System.debug('retrieveTerritoriesByParent [] ->');
        objSessionPartition = Cache.Session.getPartition('local.Territory');
        objSessionPartition.put('SelectedTerritory', '');        
        System.debug('retrieveTerritoriesByParent [] <-');
    }
    
    private static Set<Id> retrieveTerritoriesBySelectedChild(Id strSelectedChild) {
        Territorio_Administrativo__c objTerritory = null;
        List<Territorio_Administrativo__c> lstTerritories = null;
        Set<Id> setParentTerritoriesIds = null;
        
        System.debug('retrieveTerritoriesBySelectedChild [ strSelectedChild : ' + strSelectedChild + '] ->');
        
        setParentTerritoriesIds = new Set<Id>();
        
        if(String.isNotBlank(strSelectedChild)) {           
            lstTerritories = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                              FROM Territorio_Administrativo__c 
                              WHERE Id =: strSelectedChild
                              ORDER BY Name];
            System.debug('retrieveTerritoriesBySelectedChild [ lstTerritories : ' + lstTerritories + ']');
            
            while(!lstTerritories.IsEmpty() && lstTerritories[0].ParentId__c != null) {
                System.debug('retrieveTerritoriesBySelectedChild [ lstTerritories[0].ParentId__c  : ' + lstTerritories[0].ParentId__c  + ']');
                
                setParentTerritoriesIds.add(lstTerritories[0].Id);
                
                lstTerritories = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                                  FROM Territorio_Administrativo__c 
                                  WHERE Id =: lstTerritories[0].ParentId__c
                                  ORDER BY Name];       
                
                
            }                                         
        }
        
        System.debug('retrieveTerritoriesBySelectedChild [' + setParentTerritoriesIds + '] ->');
        
        return setParentTerritoriesIds;
    }
    
    private static String retrieveUserRoleName() {
        String strUserRoleName = null;
        List<UserRole> lstUserRole = null;
        
        lstUserRole = [SELECT Name FROM UserRole WHERE Id =: UserInfo.getUserRoleId()];
        
        if(!lstUserRole.isEmpty()) {            
            strUserRoleName = lstUserRole[0].Name;
        }
        
        return strUserRoleName;
    }
}