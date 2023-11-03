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
    
    //este funcion se ejecuta cuando se deselecciona un territorio, 
    //por lo que hay que disminuir en 1 el currentselectedlevel        
    refreshCurrentSelectedLevel  : function(objComponent, objEvent, objHelper) {         
        var intComponentLevel = null;        
        var intEventLevel = null;
        
        intComponentLevel = parseInt(objComponent.get('v.level'));        
        intEventLevel = parseInt(objEvent.getParam('level'));

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
        var intComponentLevel = null;
        var intLevel = null;
        var strTerritoryId = null;
        var arrTerritories = null;

        intComponentLevel = parseInt(objComponent.get('v.level'));
        intLevel = parseInt(objEvent.getParam('level'));
        strTerritoryId = objEvent.getParam('territoryid');
        arrTerritories = objComponent.get('v.territories');
        
        if(intComponentLevel === intLevel) {
            for(var intIndex = 0; intIndex < arrTerritories.length; intIndex++) {
                arrTerritories[intIndex].IsSelected = (arrTerritories[intIndex].Id == strTerritoryId);
            }
            
            objComponent.set('v.territories', arrTerritories);
            objComponent.set('v.territorySelected', true);
        }        
    },    
    clearText : function (objComponent, objEvent, objHelper) {        
        var intCurrentLevel = null;
		var divDeleteIcon = null;
        var txtInputText = null;
        
        intCurrentLevel = objComponent.get("v.level");
		divDeleteIcon = document.getElementById('close-icon-territory' + intCurrentLevel);
        txtInputText = document.getElementById('txtSearch' + intCurrentLevel);
        
        txtInputText.value = '';
        objHelper.filterText(objComponent);
    }
})