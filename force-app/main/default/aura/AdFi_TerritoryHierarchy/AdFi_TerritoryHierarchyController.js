({
    initializeComponent : function(objComponent, objEvent, objHelper) {
        
        document.title = "Territorios";
        objHelper.retrieveRootTerritory(objComponent);
    },
    retrieveTerritories : function(objComponent, objEvent, objHelper) {
        var intLevel = null;
        var strTerritoryId = null;

        objHelper.DEBUG && console.log('[TerritoryHierarchyController]retrieveTerritories ->');
        
        intLevel = parseInt(objEvent.getParam('level'));
        strTerritoryId = objEvent.getParam('territoryid');
        
        objHelper.retrieveTerritoriesFromSalesforce(objComponent, strTerritoryId, intLevel);
        
        objHelper.DEBUG && console.log('[TerritoryHierarchyController]retrieveTerritories <-');
    },
    updateSelectedTerritory : function(objComponent, objEvent, objHelper) { 
        var strTerritoryId = null;
        
        objHelper.DEBUG && console.log('[TerritoryHierarchyController]updateSelectedTerritory ->');
        
        strTerritoryId = objEvent.getParam('territoryid');
        objHelper.saveSelectedTerritory(objComponent, strTerritoryId);
        
        objHelper.DEBUG && console.log('[TerritoryHierarchyController]updateSelectedTerritory <-');
    }
})