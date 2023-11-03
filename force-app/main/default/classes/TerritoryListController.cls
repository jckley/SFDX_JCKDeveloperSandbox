global with sharing class TerritoryListController {

    @AuraEnabled(Cacheable=true)
    public static RemotingMessageHelper.Territory retrieveRootTerritory() {
        //de pruebas salio que en realidad el metodo sobrecargado no es el que usan los wire de los lwc.
        //llamara a @wire(retrieveRootTerritory) en realidad llama al metodo con parametros, pasandole null a cada parametro
        //por ahora, este metodo se deja para los test.
        return retrieveRootTerritory ('community', 'Argentina');
    }

    @AuraEnabled(Cacheable=true)
    public static RemotingMessageHelper.Territory retrieveRootTerritory( String context, String countryName) {

        RemotingMessageHelper.Territory objTerritory = null;
        List<Territorio_Administrativo__c> lstTerritoriesC = null;      
        Community_Config__mdt objSetting = null;
        String strRootTerritory = null;
        Integer intLevel = null;
         
        System.debug('retrieveParentTerritory with context [] ->' + context);
        
        if(context == 'community' || context == null){
            objSetting = HelperFunctions.retrieveCommunitySettings();
        
            if(objSetting != NULL) {
                System.debug('objSetting != NULL');
                strRootTerritory = objSetting.RootTerritory__c;
                intLevel = Integer.valueOf(objSetting.Root_Admin_Level__c);
            }  else {
                System.debug('else');
                strRootTerritory = 'Argentina';
                intLevel = 0;
            }
        }

        if (context == 'app'){
            strRootTerritory = countryName;
            intLevel = 0;
        }

        lstTerritoriesC = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                           FROM Territorio_Administrativo__c 
                           WHERE Nivel_Administrativo__c =: intLevel
                           AND Name =: strRootTerritory 
                           LIMIT 1];

        if(!lstTerritoriesC.isEmpty()) {
            objTerritory  = new RemotingMessageHelper.Territory(lstTerritoriesC[0]);	            
        }
        
        System.debug('retrieveParentTerritory [' + objTerritory + '] <-');
        
        return objTerritory;
    }

    @AuraEnabled(Cacheable=true)
    public static List<RemotingMessageHelper.Territory> retrieveChildTerritories(String strParentId, Integer intLevel) {
        List<Territorio_Administrativo__c> lstTerritoriesC = null;
        List<RemotingMessageHelper.Territory> lstTerritories = null;
        RemotingMessageHelper.Territory objTerritory = null;
        
        System.debug('retrieveChildTerritories [ strParentId : ' + strParentId + ' - intLevel : ' + intLevel + '] ->');
        
        lstTerritoriesC = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c 
                            FROM Territorio_Administrativo__c 
                            WHERE ParentId__c =: strParentId
                            AND Nivel_Administrativo__c =: intLevel
                            ORDER BY Name];                      
                
        lstTerritories = new List<RemotingMessageHelper.Territory>();
        for(Territorio_Administrativo__c objTerritoryC : lstTerritoriesC) {
            objTerritory = new RemotingMessageHelper.Territory(objTerritoryC);
            lstTerritories.add(objTerritory);
        }             
        
        System.debug('retrieveChildTerritories [ ' + lstTerritories + '] <-');
        
        return lstTerritories;
    }


    private Id territoryId;
    public Territorio_Administrativo__c territory {get; set;}
    public Territorio_Administrativo__c parentTerritory {get; set;}
    public Territorio_Administrativo__c grandParentTerritory {get; set;}
    public Territorio_Administrativo__c gGrandParentTerritory {get; set;}
    public Territorio_Administrativo__c gGGrandParentTerritory {get; set;}
    public List<TerritoryWrapper> superiorTerritories {get; set;}
    public List<TerritoryWrapper> childTerritories {get; set;}
    public Integer childTerritoriesSize {get; set;}
    public String parentTerritoryName {get; set;}
    
    public TerritoryListController(){
        territoryId = apexpages.currentpage().getparameters().get('id');
      
        superiorTerritories = new List<TerritoryWrapper>();
        territory = [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c, ParentId__r.Name, ParentId__r.ParentId__c, ParentId__r.ParentId__r.Name, 
                     ParentId__r.ParentId__r.ParentId__c, ParentId__r.ParentId__r.ParentId__r.Name, 
                     ParentId__r.ParentId__r.ParentId__r.ParentId__c, ParentId__r.ParentId__r.ParentId__r.ParentId__r.Name
                     FROM Territorio_Administrativo__c WHERE Id =: territoryId];
        
        if(territory.ParentId__r.ParentId__r.ParentId__r.ParentId__c != NULL){
            superiorTerritories.add(new TerritoryWrapper(new Territorio_Administrativo__c(Id = territory.ParentId__r.ParentId__r.ParentId__r.ParentId__c, Name = territory.ParentId__r.ParentId__r.ParentId__r.ParentId__r.Name, Nivel_Administrativo__c = territory.Nivel_Administrativo__c - 4, ParentId__c = NULL)));
        }
        if(territory.ParentId__r.ParentId__r.ParentId__c != NULL){
            superiorTerritories.add(new TerritoryWrapper(new Territorio_Administrativo__c(Id = territory.ParentId__r.ParentId__r.ParentId__c, Name = territory.ParentId__r.ParentId__r.ParentId__r.Name, Nivel_Administrativo__c = territory.Nivel_Administrativo__c - 3, ParentId__c = territory.ParentId__r.ParentId__r.ParentId__r.ParentId__c)));
        }
        if(territory.ParentId__r.ParentId__c != NULL){
            superiorTerritories.add(new TerritoryWrapper(new Territorio_Administrativo__c(Id = territory.ParentId__r.ParentId__c, Name = territory.ParentId__r.ParentId__r.Name, Nivel_Administrativo__c = territory.Nivel_Administrativo__c - 2, ParentId__c = territory.ParentId__r.ParentId__r.ParentId__c)));
        }
        if(territory.ParentId__c != NULL){
            superiorTerritories.add(new TerritoryWrapper(new Territorio_Administrativo__c(Id = territory.ParentId__c, Name = territory.ParentId__r.Name, Nivel_Administrativo__c = territory.Nivel_Administrativo__c - 1, ParentId__c = territory.ParentId__r.ParentId__c)));
        }
        superiorTerritories.add(new TerritoryWrapper(new Territorio_Administrativo__c(Id = territory.Id, Name = territory.Name, Nivel_Administrativo__c = territory.Nivel_Administrativo__c, ParentId__c = territory.ParentId__c)));
        
        parentTerritory = new Territorio_Administrativo__c(Id = territory.ParentId__c, Name = territory.ParentId__r.Name);
        parentTerritoryName = territory.ParentId__r.Name; //Si lo escribo tal cual en la VF da un error y no se muestra por eso se usa esta variable.
        childTerritories = new List<TerritoryWrapper>();
        for(Territorio_Administrativo__c terri : [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c FROM Territorio_Administrativo__c WHERE ParentId__c =: territoryId]){
            childTerritories.add(new TerritoryWrapper(terri));
        }
        childTerritoriesSize = childTerritories.size() > 0 ? childTerritories.size() : 0;
    }
    

    webservice static String getChildTerritories(String territoryId) {
        List<Territorio_Administrativo__c> territories =  [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c FROM Territorio_Administrativo__c WHERE ParentId__c =: territoryId];
        return JSON.serialize(territories);
    }
    
    webservice static String getChildTerritoriesWithExclusion(String territoryId, String territoryToExclude) {
        List<Territorio_Administrativo__c> territories =  [SELECT Id, Name, Nivel_Administrativo__c, ParentId__c FROM Territorio_Administrativo__c WHERE ParentId__c =: territoryId AND Id !=: territoryToExclude];
        return JSON.serialize(territories);
    }
    
    public class TerritoryWrapper {
        public Territorio_Administrativo__c territory {get;set;}
        public Integer treeLevel {get;set;}
        public String idForClass {get;set;}
        
        public TerritoryWrapper(Territorio_Administrativo__c terr){
            territory = terr;
            treeLevel = Integer.valueOf(territory.Nivel_Administrativo__c) + 1;
        }
    }
}