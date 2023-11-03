({    
    initializeComponent : function(objComponent, objEvent, objHelper) { 
        
        var objTerritory = objComponent.get('v.territory');
        if(objTerritory.IsSelected) {            
            objComponent.set('v.selected', true);
            objHelper.fireTerritorySelectEvent(objComponent, objTerritory.Id, objTerritory.Level);      
        }
    },
    
    toggleTerritorySelection : function(objComponent, objEvent, objHelper) {
        
        var boolIsSelected = objComponent.get('v.selected');
        var strTerritoryId = objEvent.currentTarget.dataset.territoryid;
        var intLevel = objEvent.currentTarget.dataset.level;
        
        if(!boolIsSelected) {          
            var objTerritory = objComponent.get('v.territory');
            objTerritory.IsSelected = true;
            objComponent.set('v.territory',objTerritory);
            objHelper.fireSaveSelectedTerritory(objComponent, strTerritoryId);            
            objHelper.fireTerritorySelectEvent(objComponent, strTerritoryId, intLevel);            
        } else {
            objHelper.fireTerritoryUnSelectEvent(objComponent, strTerritoryId, intLevel);   
        }
    },
    
    showTerritory : function(objComponent, objEvent, objHelper) {
      
        var strTerritoryId = objEvent.currentTarget.dataset.territoryid;
        var objEventFired = $A.get("e.force:navigateToSObject");
        
        objEventFired.setParams({
            "recordId": strTerritoryId,
            "slideDevName": "related"
        });
        
        objEventFired.fire();        
        objEvent.stopPropagation();
    },
    
    unselectTerritory  : function(objComponent, objEvent, objHelper) {         
        
        var boolIsSelected = objComponent.get('v.selected');

        if(boolIsSelected) {
            var intEventLevel = parseInt(objEvent.getParam('level'));
            var objTerritory = objComponent.get('v.territory');
            var intComponentLevel = parseInt(objTerritory.Level); 
                
            if(intComponentLevel >= intEventLevel ) {
                objComponent.set('v.selected',false);                
            }                
        }
    },
    
    unselectOtherTerritories  : function(objComponent, objEvent, objHelper) {         
        
        var boolIsSelected = objComponent.get('v.selected');

        if(boolIsSelected) {
            var intEventLevel = parseInt(objEvent.getParam('level'));
            var strTerritoryId = objEvent.getParam('territoryid');
            var objTerritory = objComponent.get('v.territory');
            var intComponentLevel = parseInt(objTerritory.Level); 
                
            if(intComponentLevel >= intEventLevel && strTerritoryId !== objTerritory.Id ) {
                objComponent.set('v.selected',false);
            }       
        }
    }
})