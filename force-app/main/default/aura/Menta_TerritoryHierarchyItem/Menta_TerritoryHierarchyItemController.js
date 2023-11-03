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
        
        boolIsSelected = objComponent.get('v.selected');
        strTerritoryId = objEvent.currentTarget.dataset.territoryid;
        intLevel = objEvent.currentTarget.dataset.level;
        
        if(!boolIsSelected) {             
            objHelper.fireSaveSelectedTerritory(objComponent, strTerritoryId);            
            objHelper.fireTerritorySelectEvent(objComponent, strTerritoryId, intLevel);            
        } else {
            objHelper.fireTerritoryUnSelectEvent(objComponent, strTerritoryId, intLevel);   
        }
    },
    showTerritory : function(objComponent, objEvent, objHelper) {
        var objEventFired = null;
        var strTerritoryId = null;
      
        strTerritoryId = objEvent.currentTarget.dataset.territoryid;
        
        //objHelper.saveSelectedTerritory(objComponent, strTerritoryId);
        
        objEventFired = $A.get("e.force:navigateToSObject");
        objEventFired.setParams({
            "recordId": strTerritoryId,
            "slideDevName": "related"
        });
        
        objEventFired.fire();        
        objEvent.stopPropagation();
    },    
    unselectTerritory  : function(objComponent, objEvent, objHelper) {         
        var intComponentLevel = null;
        var intEventLevel = null;
        var objTerritory = null;
        var boolIsSelected = null;
        
        boolIsSelected = objComponent.get('v.selected');

        if(boolIsSelected === true) {
            intEventLevel = parseInt(objEvent.getParam('level'));
            objTerritory = objComponent.get('v.territory');
            intComponentLevel = parseInt(objTerritory.Level); 
                
            if(intComponentLevel >= intEventLevel ) {
                objComponent.set('v.selected',false);                
            }                
        }
    },
    unselectOtherTerritories  : function(objComponent, objEvent, objHelper) {         
        var intComponentLevel = null;
        var intEventLevel = null;
        var objTerritory = null;
        var strTerritoryId = null;
        var boolIsSelected = null;
        
        boolIsSelected = objComponent.get('v.selected');

        if(boolIsSelected === true) {
            intEventLevel = parseInt(objEvent.getParam('level'));
            strTerritoryId = objEvent.getParam('territoryid');
            objTerritory = objComponent.get('v.territory');
            intComponentLevel = parseInt(objTerritory.Level); 
                
            if(intComponentLevel >= intEventLevel && strTerritoryId !== objTerritory.Id ) {
                objComponent.set('v.selected',false);
                
                /*if(intComponentLevel === intEventLevel) {
                    console.log(objComponent.find('divTerritory').getElement().classList);
                    console.log('territory : ' + objComponent.get('v.territory').Name);

                    objHelper.addClass(objComponent)
                }*/
                
            }       
        }
    }
})