({
    DEBUG : true,
	retrieveOptionsFromSalesforce : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var arrOptions = null;
        var objThat = this;
    	var strRecordId = null;
        var strField = null;
        var strSObject = null;
        
        this.DEBUG && console.log('[CommunityFieldHelper]retrieveOptionsFromSalesforce ->');
        
        strRecordId = objComponent.get('v.recordId'); 
        strField = objComponent.get('v.field'); 
        strSObject =  objComponent.get('v.sobject');
        
        objControllerAction = objComponent.get("c.retrieveMultipicklistOptions"); 
        objControllerAction.setParams( {
            'strSObject' : strSObject,
            'strField' : strField
        });

        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            
            if (objComponent.isValid() && strState === "SUCCESS") {
                arrOptions = JSON.parse(objResponse.getReturnValue());
                objComponent.set('v.options', arrOptions);      
                objComponent.set('v.filteredOptions', []); 
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
        
        this.DEBUG && console.log('[CommunityFieldHelper]retrieveOptionsFromSalesforce <-');
	},
    selectOptions : function(objComponent, strOptionText) {
        var objOption = null;
        var arrOptions = null;
        var boolHasOption = false;
        var strOptions = null;
        
        this.DEBUG && console.log('[CommunityFieldHelper]selectOptions ->');
        
        if(strOptionText !== undefined && strOptionText !== null && strOptionText.length > 0) {
            arrOptions = objComponent.get('v.selectedOptions');
            objComponent.set('v.filteredOptions', []);
            objComponent.find('cboCommunity').set('v.value', '');
            
            if(arrOptions === undefined || arrOptions === null) {
                arrOptions = [];
            }
            
            for(var intIndex = 0; intIndex < arrOptions.length; intIndex++) {
                if(arrOptions[intIndex].label === strOptionText) {
                    boolHasOption = true;                    
                    break;
                }
            }
            
            if(!boolHasOption) {                
                objOption = {};
                objOption.label = strOptionText;
                objOption.value = strOptionText;
                
                arrOptions.push(objOption);
                if(arrOptions.length === 1) {
                    strOptions = objOption.value;                    
                } else {
                    strOptions = objComponent.get('v.value') + ';' + objOption.value; 
                }              
                
                objComponent.set('v.value', strOptions);
                
                this.addNewOptionsIfNotExists(objComponent, strOptionText);
            }
        }             
    },    
    addNewOptionsIfNotExists : function(objComponent, strOptionText) {
        var objOption = null;
        var arrOptions = null;
        var boolHasOption = false;
        
        arrOptions = objComponent.get('v.options');
        
        if(arrOptions === undefined || arrOptions === null) {
            arrOptions = [];
        }
        
        for(var intIndex = 0; intIndex < arrOptions.length; intIndex++) {
            if(arrOptions[intIndex].label === strOptionText) {
                boolHasOption = true;                    
                break;
            }
        }
        
        if(!boolHasOption) {
            objOption = {};
            objOption.label = strOptionText;
            objOption.value = strOptionText;
            
            arrOptions.push(objOption);
            objComponent.set('v.options', arrOptions); 
        }

    },
	saveOptionsToSalesforce : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var objThat = this;
    	var strField = null;
        var strRecordId = null;
        var arrOptions = null;
        
        this.DEBUG && console.log('[CommunityFieldHelper]saveOptionsToSalesforce ->');
        
        strRecordId = objComponent.get('v.recordId'); 
        strField = objComponent.get('v.field'); 
        arrOptions = objComponent.get('v.selectedOptions');
        
        objControllerAction = objComponent.get("c.saveSelectedOptions"); 
        objControllerAction.setParams( {
            'strSObject' : 'Contact',
            'strField' : strField,
            'strRecordId': strRecordId,
            'arrSelectedOptions' : arrOptions,
        });
        
        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            
            if (objComponent.isValid() && strState === "SUCCESS") {
                 this.DEBUG && console.log('[CommunityFieldHelper]saveOptionsToSalesforce - OPTIONS SAVED SUCCESFULLY');
            } else {
                this.DEBUG && console.log('[CommunityFieldHelper]saveOptionsToSalesforce - FAILED TO SAVE OPTIONS');
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
        
        this.DEBUG && console.log('[CommunityFieldHelper]saveOptionsToSalesforce <-');
	}
})