({    
    initializeComponent : function(objComponent, objEvent, objHelper) {         
        var objTerritory = null;
        
        objTerritory = objComponent.get('v.territory');
        if(objTerritory !== undefined && objTerritory !== null && objTerritory.IsSelected) {            
            objComponent.set('v.selected', true);
            objHelper.fireTerritorySelectEvent(objComponent, objTerritory.Id, objTerritory.Level);      
        }
    },
    
    toggleTerritorySelection : function(objComponent, objEvent, objHelper) {        
        var boolIsSelected = null;
        var strTerritoryId = null;
        var intLevel = null;
        
        boolIsSelected = objComponent.get('v.selected');
        strTerritoryId = objEvent.currentTarget.dataset.territoryid;
        intLevel = objEvent.currentTarget.dataset.level;
        
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
        var strTerritoryId = null;
        var objEventFired = null;
                    
        strTerritoryId = objEvent.currentTarget.dataset.territoryid;
        objEventFired = $A.get("e.force:navigateToSObject");
        
        objEventFired.setParams({
            "recordId": strTerritoryId,
            "slideDevName": "related"
        });
        
        objEventFired.fire();        
        objEvent.stopPropagation();
    },    
    unselectTerritory  : function(objComponent, objEvent, objHelper) {         
        var intEventLevel = null;
        var objTerritory = null;
        var intComponentLevel = null; 
        var boolIsSelected = null;

        boolIsSelected = objComponent.get('v.selected');

        if(boolIsSelected) {
            intEventLevel = parseInt(objEvent.getParam('level'));
            objTerritory = objComponent.get('v.territory');
            intComponentLevel = parseInt(objTerritory.Level); 
                
            if(intComponentLevel >= intEventLevel ) {
                objComponent.set('v.selected',false);                
            }                
        }
    },    
    unselectOtherTerritories  : function(objComponent, objEvent, objHelper) {       
        var intEventLevel = null;
        var strTerritoryId = null;
        var objTerritory = null;
        var intComponentLevel = null;        
        var boolIsSelected = null;

        boolIsSelected = objComponent.get('v.selected');
        if(boolIsSelected) {
            intEventLevel = parseInt(objEvent.getParam('level'));
            strTerritoryId = objEvent.getParam('territoryid');
            objTerritory = objComponent.get('v.territory');
            intComponentLevel = parseInt(objTerritory.Level); 
                
            if(intComponentLevel >= intEventLevel && strTerritoryId !== objTerritory.Id ) {
                objComponent.set('v.selected',false);
            }       
        }
    }
})