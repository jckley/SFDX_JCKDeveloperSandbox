({
    DEBUG : false,
	fireTerritorySelectEvent : function(objComponent, strTerritoryId, intLevel) {

        objComponent.set('v.selected', true);
        
        var objEventFired = $A.get("e.c:TerritoryHierarchySelectEvent");
        objEventFired.setParam('level', intLevel);
        objEventFired.setParam('territoryid', strTerritoryId);                
        objEventFired.fire();
	},
    fireTerritoryUnSelectEvent : function(objComponent, strTerritoryId, intLevel) {
        
        objComponent.set('v.selected', true);
        
        var objEventFired = $A.get("e.c:TerritoryHierarchyUnselectTerritoryEvent");
        objEventFired.setParam('level', intLevel);
        objEventFired.setParam('territoryid', strTerritoryId);                
        objEventFired.fire();
	},
    fireSaveSelectedTerritory : function(objComponent, strTerritoryId, intLevel) {
        
        var objEventFired = $A.get("e.c:TerritoryHierarchySaveSelectedEvent");
        objEventFired.setParam('level', intLevel);
        objEventFired.setParam('territoryid', strTerritoryId);                
        objEventFired.fire();
	}
})