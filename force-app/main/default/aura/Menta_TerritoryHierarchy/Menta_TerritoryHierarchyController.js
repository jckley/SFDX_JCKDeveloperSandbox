({
    initializeComponent : function(objComponent, objEvent, objHelper) {
        objHelper.retrieveRootTerritory(objComponent);
    },
    retrieveTerritories : function(objComponent, objEvent, objHelper) {
        var intLevel = null;
        var strTerritoryId = null;

        intLevel = parseInt(objEvent.getParam('level'));
        strTerritoryId = objEvent.getParam('territoryid');
        
        objHelper.retrieveTerritoriesFromSalesforce(objComponent, strTerritoryId, intLevel);
    },
    updateSelectedTerritory : function(objComponent, objEvent, objHelper) { 
        var strTerritoryId = null;
        
        strTerritoryId = objEvent.getParam('territoryid');
        objHelper.saveSelectedTerritory(objComponent, strTerritoryId);
    },
    handleRouteChange : function(objComponent, objEvent, objHelper) { 
        objHelper.DEBUG && console.log('[TerritoryHierarchyController]handleRouteChange ->');
        
        //objHelper.clearSelectedTerritory(objComponent);
        
        objHelper.DEBUG && console.log('[TerritoryHierarchyController]handleRouteChange <-');
    }
})