({
    loadRetrievedTerritories : function(objComponent, objEvent, objHelper) {
        var intEventLevel = null;
        var intComponentLevel = null;
        var arrTerritories = null;
        var strSelectedTerritoryId = null;
        var divLevel = null;
        var divEmptyLevel = null;
        
        intEventLevel = parseInt(objEvent.getParam('level')) ;
        arrTerritories = objEvent.getParam('territories');
        intComponentLevel = parseInt(objComponent.get('v.level'));
        
        objComponent.set('v.currentSelectedLevel', intEventLevel);
        objComponent.set('v.showingLevel', ( (intEventLevel + 1) <= intComponentLevel ) );
        
        divLevel = document.getElementById('divLevel' + intComponentLevel);
        divEmptyLevel =  document.getElementById('divEmptyLevel' + intComponentLevel);
        //si el nivel del componente instanciado es igual al nivel del evento disparado,
        //entonces cargo los territorios en el componente
        if(parseInt(intComponentLevel) === parseInt(intEventLevel) + 1) {            
            if(arrTerritories.length == 0) {
                if(divLevel.style !== undefined && divLevel.style !== null && divLevel.style.length > 0) {
                    if(!divEmptyLevel.style.hasOwnProperty('display')) {
                        divLevel.style += 'display:none;';
                        divEmptyLevel.style += 'display:none;';
                    }
                } else {
                    divLevel.style = 'display:none;';                          
                    divEmptyLevel.style = 'display:none;';
                }
            } else {
                if(divLevel.style !== undefined && divLevel.style !== null && divLevel.style.length > 0) {
                    divLevel.style.removeProperty("display");    
                    divEmptyLevel.style.removeProperty("display");                                                                                    
                }
            }
            	
            objComponent.set('v.territories', arrTerritories);            
            objComponent.set('v.filteredTerritories', arrTerritories);            
        } else if(parseInt(intComponentLevel) > parseInt(intEventLevel) + 1) {
            //si el nivel del componente es mayor al nivel del evento,
            //hay que borrar los territorios del componente.
            objComponent.set('v.territories',  []);  
            objComponent.set('v.filteredTerritories', []);
            
            if(divLevel.style !== undefined && divLevel.style !== null && divLevel.style.length > 0) {
                divLevel.style.removeProperty("display");  
                divEmptyLevel.style.removeProperty("display"); 
            }
        }
	}, 
    filterEntries : function(objComponent, objEvent, objHelper) {
        objHelper.filterText(objComponent);
    },
    refreshCurrentSelectedLevel  : function(objComponent, objEvent, objHelper) { 
        var intComponentLevel = null;
        var intEventLevel = null;
        //este funcion se ejecuta cuando se desselecciona un territorio, por lo que hay que disminuir en 1 el currentselectedlevel        
        
        intComponentLevel = parseInt(objComponent.get('v.level'));        
        intEventLevel = parseInt(objEvent.getParam('level'));
         objComponent.set('v.showingLevel', ( (intEventLevel + 1 ) <= intComponentLevel ) );
        if(intComponentLevel > intEventLevel ) {
            objComponent.set('v.hasItemSeleted', false);
        	objComponent.set('v.territories', []);
            objComponent.set('v.filteredTerritories', []);
        }
        if(intComponentLevel == intEventLevel ) { 
            objComponent.set('v.hasItemSeleted', false);        
        }

        objComponent.set('v.currentSelectedLevel', parseInt(intEventLevel) - 1);
        /*objHelper.territoryUnSelected();*/
    },
    updateSelectedTerritory : function(objComponent, objEvent, objHelper) {
        var intComponentLevel = null;
        var intLevel = null;
        var strTerritoryId = null;
        var arrTerritories = null;
        
        objHelper.DEBUG && console.log('[TerritoryHierarchylevelController]saveSelectedTerritory ->');
        
        intComponentLevel = parseInt(objComponent.get('v.level'));
        intLevel = parseInt(objEvent.getParam('level'));
        strTerritoryId = objEvent.getParam('territoryid');
        arrTerritories = objComponent.get('v.territories');
        
        if(intComponentLevel === intLevel) {
            objComponent.set('v.hasItemSeleted', true);
            
            for(var intIndex = 0; intIndex < arrTerritories.length; intIndex++) {
                arrTerritories[intIndex].IsSelected = (arrTerritories[intIndex].Id == strTerritoryId);
            }
            
            objComponent.set('v.territories', arrTerritories);
        } else if (intComponentLevel > intLevel) {
            objComponent.set('v.hasItemSeleted', false);            
        }        
        
        objHelper.DEBUG && console.log('[TerritoryHierarchylevelController]saveSelectedTerritory <-');
    },
    
    clearText : function (objComponent, objEvent, objHelper) {
        var currentLevel = objComponent.get("v.level");
		var deleteIcon = document.getElementById('close-icon-territory' + currentLevel);
        var inputText = document.getElementById('txtSearch' + currentLevel);
        inputText.value = '';
        objHelper.filterText(objComponent);
    }    
    /*territorySelected : function (component, event, helper) {
        helper.territorySelected();
    }*/
})