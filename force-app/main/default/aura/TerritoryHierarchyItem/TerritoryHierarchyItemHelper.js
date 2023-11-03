({
    DEBUG : false,
	fireTerritorySelectEvent : function(objComponent, strTerritoryId, intLevel) {
        var objEventFired = null; 
        
        this.DEBUG && console.log('[TerritoryHierarchyItemHelper]fireTerritorySelectEvent [strTerritoryId : ' + strTerritoryId + ' - intLevel : ' + intLevel + '] ->');
             
        this.DEBUG && console.log('[TerritoryHierarchyItemHelper]fireTerritorySelectEvent [firing TerritoryHierarchySelectEvent]');     
        
        objComponent.set('v.selected', true);
        
        objEventFired = $A.get("e.c:TerritoryHierarchySelectEvent");
        objEventFired.setParam('level', intLevel);
        objEventFired.setParam('territoryid', strTerritoryId);                
        objEventFired.fire();
        
        this.DEBUG && console.log('[TerritoryHierarchyItemHelper]fireTerritorySelectEvent <-');        
	},
    fireTerritoryUnSelectEvent : function(objComponent, strTerritoryId, intLevel) {
        var objEventFired = null; 
        
        this.DEBUG && console.log('[TerritoryHierarchyItemHelper]fireTerritoryUnSelectEvent [strTerritoryId : ' + strTerritoryId + ' - intLevel : ' + intLevel + '] ->');
             
        this.DEBUG && console.log('[TerritoryHierarchyItemHelper]fireTerritoryUnSelectEvent [firing TerritoryHierarchyUnselectTerritoryEvent]');     
        
        objComponent.set('v.selected', true);
        
        objEventFired = $A.get("e.c:TerritoryHierarchyUnselectTerritoryEvent");
        objEventFired.setParam('level', intLevel);
        objEventFired.setParam('territoryid', strTerritoryId);                
        objEventFired.fire();
        
        this.DEBUG && console.log('[TerritoryHierarchyItemHelper]fireTerritoryUnSelectEvent <-');        
	},
    fireSaveSelectedTerritory : function(objComponent, strTerritoryId, intLevel) {
        var objEventFired = null; 
        
        this.DEBUG && console.log('[TerritoryHierarchyItemHelper]fireSaveSelectedTerritory [strTerritoryId : ' + strTerritoryId + ' - intLevel : ' + intLevel + '] ->');
             
        this.DEBUG && console.log('[TerritoryHierarchyItemHelper]fireSaveSelectedTerritory [firing TerritoryHierarchySaveSelectedEvent]');     
        
        objEventFired = $A.get("e.c:TerritoryHierarchySaveSelectedEvent");
        objEventFired.setParam('territoryid', strTerritoryId);                
        objEventFired.fire();
        
        this.DEBUG && console.log('[TerritoryHierarchyItemHelper]fireSaveSelectedTerritory <-');        
	}
})