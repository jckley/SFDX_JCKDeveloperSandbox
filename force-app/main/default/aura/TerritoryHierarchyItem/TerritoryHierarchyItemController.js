({    
    initializeComponent : function(objComponent, objEvent, objHelper) { 
    	var objTerritory = null;
        
        objTerritory = objComponent.get('v.territory');
        if(objTerritory.IsSelected) {            
            objComponent.set('v.selected', true);
            objHelper.fireTerritorySelectEvent(objComponent, objTerritory.Id, objTerritory.Level);      
        }
    },
    toggleTerritorySelection : function(objComponent, objEvent, objHelper) {
        var intLevel = null;
        var strTerritoryId = null;
        var boolIsSelected = false;
        
        objHelper.DEBUG && console.log('[TerritoryHierarchyItemController]selectTerritory ->');
        
        boolIsSelected = objComponent.get('v.selected');
        strTerritoryId = objEvent.currentTarget.dataset.territoryid;
        intLevel = objEvent.currentTarget.dataset.level;
        
        console.log('[TerritoryHierarchyItemController]selectTerritory [ strTerritoryId : ' + strTerritoryId + ' - intLevel : ' + intLevel + ']');
        
        if(!boolIsSelected) {             
            objHelper.fireSaveSelectedTerritory(objComponent, strTerritoryId);            
            objHelper.fireTerritorySelectEvent(objComponent, strTerritoryId, intLevel);            
        } else {
            objHelper.fireTerritoryUnSelectEvent(objComponent, strTerritoryId, intLevel);   
        }
        objHelper.DEBUG && console.log('[TerritoryHierarchyItemController]selectTerritory <-');        
    },
    showTerritory : function(objComponent, objEvent, objHelper) {
        var objEventFired = null;
        var strTerritoryId = null;
        
        objHelper.DEBUG && console.log('[TerritoryHierarchyItemController]showTerritory ->');
      
        strTerritoryId = objEvent.currentTarget.dataset.territoryid;
        
        //objHelper.saveSelectedTerritory(objComponent, strTerritoryId);
        
        objEventFired = $A.get("e.force:navigateToSObject");
        objEventFired.setParams({
            "recordId": strTerritoryId,
            "slideDevName": "related"
        });
        
        objEventFired.fire();        
        objEvent.stopPropagation();
        
        objHelper.DEBUG && console.log('[TerritoryHierarchyItemController]showTerritory <-');
    },    
    unselectTerritory  : function(objComponent, objEvent, objHelper) {         
        var intComponentLevel = null;
        var intEventLevel = null;
        var objTerritory = null;
        var boolIsSelected = null;
        
        objHelper.DEBUG && console.log('[TerritoryHierarchyItemController]unselectTerritory ->');
        
        boolIsSelected = objComponent.get('v.selected');

        if(boolIsSelected === true) {
            intEventLevel = parseInt(objEvent.getParam('level'));
            objTerritory = objComponent.get('v.territory');
            intComponentLevel = parseInt(objTerritory.Level); 
                
            if(intComponentLevel >= intEventLevel ) {
                objComponent.set('v.selected',false);                
            }                
        }
        
        objHelper.DEBUG && console.log('[TerritoryHierarchyItemController]unselectTerritory <-');
    },
    unselectOtherTerritories  : function(objComponent, objEvent, objHelper) {         
        var intComponentLevel = null;
        var intEventLevel = null;
        var objTerritory = null;
        var strTerritoryId = null;
        var boolIsSelected = null;
        
        objHelper.DEBUG && console.log('[TerritoryHierarchyItemController]unselectOtherTerritories ->');
        
        boolIsSelected = objComponent.get('v.selected');

        if(boolIsSelected === true) {
            intEventLevel = parseInt(objEvent.getParam('level'));
            strTerritoryId = objEvent.getParam('territoryid');
            objTerritory = objComponent.get('v.territory');
            intComponentLevel = parseInt(objTerritory.Level); 
                
            if(intComponentLevel >= intEventLevel && strTerritoryId !== objTerritory.Id ) {
                objComponent.set('v.selected',false);
            }       
        }
        
        objHelper.DEBUG &&  console.log('[TerritoryHierarchyItemController]unselectOtherTerritories <-');
    }
})