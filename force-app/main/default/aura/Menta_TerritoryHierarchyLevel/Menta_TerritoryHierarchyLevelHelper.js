({
    filterText : function (objComponent) {
        var currentLevel = objComponent.get("v.level");
        var strSearchText = null;
        var arrTerritories = null;
        var arrTerritoriesFounded = null;
		var deleteIcon = document.getElementById('close-icon-territory' + currentLevel);
        
        strSearchText = document.getElementById('txtSearch' + currentLevel).value;
        arrTerritories = objComponent.get('v.territories');
        arrTerritoriesFounded = [];
        
        if(strSearchText != ''){
            deleteIcon.classList.remove("slds-hide");
        } else {
            deleteIcon.classList.add("slds-hide");
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
    }
    
    /*territorySelected: function() {
        var allTerritories = document.getElementsByClassName("territory");
        console.log(allTerritories.length);
        for (var i = 0; i < allTerritories.length; i++) {
            if(!allTerritories[i].classList.contains('selected')){
                allTerritories[i].classList.add('not-selected');
            }
        }
    },
    
    territoryUnSelected: function() {
        var allTerritories = document.getElementsByClassName("not-selected");
        for (var i = 0; i < allTerritories.length; i++) {
            allTerritories[i].classList.remove('not-selected');
        }
    }*/
})