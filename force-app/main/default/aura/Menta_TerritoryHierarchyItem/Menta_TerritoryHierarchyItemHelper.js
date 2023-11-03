({
    DEBUG : false,
	fireTerritorySelectEvent : function(objComponent, strTerritoryId, intLevel) {
        var objEventFired = null; 

        objComponent.set('v.selected', true);
        objEventFired = $A.get("e.c:TerritoryHierarchySelectEvent");
        objEventFired.setParam('level', intLevel);
        objEventFired.setParam('territoryid', strTerritoryId);                
        objEventFired.fire();
	},
    fireTerritoryUnSelectEvent : function(objComponent, strTerritoryId, intLevel) {
        var objEventFired = null; 
        
        objComponent.set('v.selected', true);
        
        objEventFired = $A.get("e.c:TerritoryHierarchyUnselectTerritoryEvent");
        objEventFired.setParam('level', intLevel);
        objEventFired.setParam('territoryid', strTerritoryId);                
        objEventFired.fire();
	},
    fireSaveSelectedTerritory : function(objComponent, strTerritoryId, intLevel) {
        var objEventFired = null; 
        
        objEventFired = $A.get("e.c:TerritoryHierarchySaveSelectedEvent");
        objEventFired.setParam('territoryid', strTerritoryId);                
        objEventFired.fire();
	},
    
})