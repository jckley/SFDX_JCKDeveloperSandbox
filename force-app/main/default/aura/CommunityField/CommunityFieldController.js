({
    retrieveOptions : function(objComponent, objEvent, objHelper) {
        objHelper.retrieveOptionsFromSalesforce(objComponent);        
    },
    filterEntries : function(objComponent, objEvent, objHelper) {
        var arrOptions = null;
        var arrFilteredOptions = null;
        var strFilterText = null;
        
        arrOptions = objComponent.get('v.options');
        strFilterText = objComponent.find('cboCommunity').get('v.value');
        
        if(arrOptions === undefined || arrOptions === null ) {
            arrOptions = [];
        }
        if(strFilterText !== undefined && strFilterText !== null && strFilterText.length > 0) {
            arrFilteredOptions = arrOptions.filter(objItem => objItem.value.toLowerCase().indexOf(strFilterText.toLowerCase()) >= 0);
            
            objComponent.set('v.filteredOptions', arrFilteredOptions);
        } else {
            objComponent.set('v.filteredOptions', []);            
        }
    },
    addNewOption : function(objComponent, objEvent, objHelper) { 
        var strOptionText = null;
        
        if(objEvent.keyCode == 13 || objEvent.keyCode == 9) {                    
            strOptionText = objComponent.find('cboCommunity').get('v.value');
                
            objHelper.selectOptions(objComponent, strOptionText);
            
            objEvent.stopPropagation();      
            objComponent.find('cboCommunity').focus();
        }
    },
    addOptionSelected : function(objComponent, objEvent, objHelper) {        
        if(objEvent.currentTarget !== undefined && objEvent.currentTarget !== null && objEvent.currentTarget.dataset !== undefined && objEvent.currentTarget.dataset !== null && objEvent.currentTarget.dataset.label !== undefined && objEvent.currentTarget.dataset.label !== null && objEvent.currentTarget.dataset.label.length > 0) {             
            objHelper.selectOptions(objComponent, objEvent.currentTarget.dataset.value);
        } 
    },
    removeSelectedOption : function(objComponent, objEvent, objHelper) {
        var arrOptions = null;
        var strOptions = null;
        arrOptions = objComponent.get('v.selectedOptions');
        
        if(arrOptions !== undefined && arrOptions !== null && arrOptions.length > 0) {
            if(objEvent.currentTarget !== undefined && objEvent.currentTarget !== null && objEvent.currentTarget.dataset !== undefined && objEvent.currentTarget.dataset !== null) {                 
                arrOptions = arrOptions.filter(objItem => objItem.value !== objEvent.currentTarget.dataset.value);
                
                strOptions = '';
                for(var intIndex = 0; intIndex < arrOptions.length; intIndex++) {
                    if(intIndex > 0) {
                        strOptions += ';';
                    } 
                    strOptions += arrOptions[intIndex].value;
                }
                
                objComponent.set('v.value', strOptions);
            }	
        }        
    },
    onOptionsChange : function(objComponent, objEvent, objHelper) {
      	var strValue = null;
        var arrOptions = null;
        var arrOptionsResult = null;
        var objOption = null;

        strValue = objComponent.get('v.value');
        arrOptionsResult = [];
        
        if(strValue !== undefined && strValue !== null && strValue.length > 0) {
            arrOptions = strValue.split(';');
            for(var intIndex = 0; intIndex < arrOptions.length; intIndex++) {
                objOption = {};
                objOption.label = arrOptions[intIndex];
                objOption.value = arrOptions[intIndex];    
                
                arrOptionsResult.push(objOption);
            }
        } 
                
        objComponent.set('v.selectedOptions', arrOptionsResult);
    },
    saveSelectedOptions : function(objComponent, objEvent, objHelper) {
        objHelper.saveOptionsToSalesforce(objComponent);
    }
})