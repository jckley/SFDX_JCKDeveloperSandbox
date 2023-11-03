({
    initializeComponent : function(objComponent, objEvent, objHelper) {
        objHelper.DEBUG && console.log('[TerritoryHierarchyController]initializeComponent ->');        
        
        objHelper.retrieveRootTerritory(objComponent);
        
        objHelper.DEBUG && console.log('[TerritoryHierarchyController]initializeComponent <-');
    },
    
    refreshChartData : function(component, event, helper) {
        console.log('Entra al controlador');
        var territoryId = component.get('v.recordId');
        helper.retrieveChartData(component, territoryId);
    }
})