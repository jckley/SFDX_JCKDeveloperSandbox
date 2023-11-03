({
    loadRetrievedTerritories : function(objComponent, objEvent, objHelper) {
        
        var intEventLevel = parseInt(objEvent.getParam('level')) ;
        var arrTerritories = objEvent.getParam('territories');
        var intComponentLevel = parseInt(objComponent.get('v.level'));
        
        objComponent.set('v.currentSelectedLevel', intEventLevel);
        objComponent.set('v.showingLevel', ( (intEventLevel + 1) <= intComponentLevel ) );
        
        var divLevel = document.getElementById('divLevel' + intComponentLevel);
        var divEmptyLevel =  document.getElementById('divEmptyLevel' + intComponentLevel);
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
        
        //este funcion se ejecuta cuando se deselecciona un territorio, 
        //por lo que hay que disminuir en 1 el currentselectedlevel        

        var intComponentLevel = parseInt(objComponent.get('v.level'));        
        var intEventLevel = parseInt(objEvent.getParam('level'));
        objComponent.set('v.showingLevel', ( (intEventLevel + 1 ) <= intComponentLevel ) );
        
        if(intComponentLevel > intEventLevel ) {
            objComponent.set('v.territories', []);
            objComponent.set('v.filteredTerritories', []);
        }
        
        objComponent.set('v.currentSelectedLevel', parseInt(intEventLevel) - 1);
        if(intComponentLevel == intEventLevel){
        	objComponent.set('v.territorySelected', false);   
        }
    },
    
    updateSelectedTerritory : function(objComponent, objEvent, objHelper) {
        
        var intComponentLevel = parseInt(objComponent.get('v.level'));
        var intLevel = parseInt(objEvent.getParam('level'));
        var strTerritoryId = objEvent.getParam('territoryid');
        var arrTerritories = objComponent.get('v.territories');
        if(intComponentLevel === intLevel) {
            for(var intIndex = 0; intIndex < arrTerritories.length; intIndex++) {
                arrTerritories[intIndex].IsSelected = (arrTerritories[intIndex].Id == strTerritoryId);
            }
            
            objComponent.set('v.territories', arrTerritories);
            objComponent.set('v.territorySelected', true);
        }        
    },
    
    clearText : function (objComponent, objEvent, objHelper) {
        
        var currentLevel = objComponent.get("v.level");
		var deleteIcon = document.getElementById('close-icon-territory' + currentLevel);
        var inputText = document.getElementById('txtSearch' + currentLevel);
        
        inputText.value = '';
        objHelper.filterText(objComponent);
    }
})