({
    DEBUG : false,
    filterText : function (objComponent) {
        var strSearchText = null;
        var arrTerritories = null;
        var arrTerritoriesFounded = null;
        var intCurrentLevel = null;
		var imgDeleteIcon = null;
        
        this.DEBUG && console.log('[TerritoryHierarchylevelController]filterText ->');
        intCurrentLevel = objComponent.get("v.level");
        imgDeleteIcon = document.getElementById('close-icon-territory' + intCurrentLevel);
        strSearchText = document.getElementById('txtSearch' + intCurrentLevel).value;
        arrTerritories = objComponent.get('v.territories');
        arrTerritoriesFounded = [];
        
        if(strSearchText !== undefined && strSearchText !== null && strSearchText.length > 0) {
            imgDeleteIcon.classList.remove("slds-hide");
        } else {
            imgDeleteIcon.classList.add("slds-hide");
        }
        
        if(arrTerritories !== undefined && arrTerritories !== null && arrTerritories.length > 0) {
            if(strSearchText !== undefined && strSearchText !== null && strSearchText.length > 0) {
                strSearchText = strSearchText.toUpperCase();
                for(var intIndex = 0; intIndex < arrTerritories.length; intIndex++) {
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