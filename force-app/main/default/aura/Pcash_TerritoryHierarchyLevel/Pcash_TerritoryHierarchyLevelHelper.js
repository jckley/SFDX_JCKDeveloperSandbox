({
    DEBUG : false,
    filterText : function (objComponent) {
        var strSearchText = null;
        var arrTerritories = null;
        var arrTerritoriesFounded = null;
        var currentLevel = objComponent.get("v.level");
		var deleteIcon = document.getElementById('close-icon-territory' + currentLevel);
        
        this.DEBUG && console.log('[TerritoryHierarchylevelController]filterText ->');
        strSearchText = document.getElementById('txtSearch' + currentLevel).value;
        arrTerritories = objComponent.get('v.territories');
        arrTerritoriesFounded = [];
        
        if(strSearchText != '') {
            deleteIcon.classList.remove("slds-hide");
        } else {
            deleteIcon.classList.add("slds-hide");
        }
        
        if(arrTerritories !== undefined && arrTerritories !== null && arrTerritories.length > 0) {
            if(strSearchText !== undefined && strSearchText !== null && strSearchText.length > 0) {
                strSearchText = strSearchText.toUpperCase();
                for(var intIndex = 0; intIndex < arrTerritories.length; intIndex++) {
                    if(arrTerritories[intIndex].IsSelected) {                        
	                    console.log(arrTerritories[intIndex].Name +  ' : ' + arrTerritories[intIndex].IsSelected);
                    }
                    
                    if(arrTerritories[intIndex].Name.toUpperCase().includes(strSearchText)) {
                        arrTerritoriesFounded.push(arrTerritories[intIndex]);                    
                    }
                }
            } else {
                arrTerritoriesFounded = arrTerritories;
            }            
        }

        objComponent.set('v.filteredTerritories', arrTerritoriesFounded);
        this.DEBUG && console.log('[TerritoryHierarchylevelController]filterText <-');
    }
})