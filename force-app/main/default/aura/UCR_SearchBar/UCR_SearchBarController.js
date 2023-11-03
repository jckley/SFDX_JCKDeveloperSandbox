({        
    initializeComponent : function(objComponent, objEvent, objHelper) {
        var strSearchText = null;

        if(window.location.href.indexOf('global-search') >= 0 ) {
            strSearchText = window.location.href.substring(window.location.href.indexOf('global-search') + 'global-search'.length + 1);
            strSearchText = decodeURIComponent(strSearchText);
           	objComponent.set('v.searchText', strSearchText);
        }   
    },
    searchText : function(objComponent, objEvent, objHelper) {
        var strSearchText = objComponent.find('enter-search').getElement().value;
        objComponent.set('v.searchText',strSearchText);
        // Number 13 is the "Enter" key on the keyboard
        if (objEvent.keyCode === 13) {
            var searchEvent = $A.get("e.c:SearchEvent");
            searchEvent.setParams({searchType: ''});
            searchEvent.fire();
            var navEvt = $A.get('e.force:navigateToURL');
            navEvt.setParams({url: '/global-search/' + strSearchText});
            navEvt.fire();
        } else {
            if(strSearchText !== undefined && strSearchText !== null && strSearchText.length > 0) {
                objHelper.retrieveResults(objComponent, strSearchText);            
            } else {
                objHelper.clearResults(objComponent);            
            }
        }
    },
    onFocus : function (objComponent, objEvent, objHelper) {
        objComponent.find('guide').getElement().classList.remove("slds-hidden");
        var searchTxt = objComponent.find('enter-search').getElement().value;
        if(searchTxt != ''){
            objComponent.find('search-icon').getElement().classList.remove("slds-hide");
            objComponent.find('close-icon').getElement().classList.add("slds-hide");
        }
    },
    onBlur : function (objComponent, objEvent, objHelper) {
        objComponent.find('guide').getElement().classList.add("slds-hidden");
        var searchTxt = objComponent.find('enter-search').getElement().value;
        if(searchTxt != ''){
            objComponent.find('search-icon').getElement().classList.add("slds-hide");
            objComponent.find('close-icon').getElement().classList.remove("slds-hide");
        }
        setTimeout(function(){objHelper.clearResults(objComponent)}, 500);
        objEvent.stopPropagation();
    },
    clearText : function (objComponent, objEvent, objHelper) {
        objComponent.find('enter-search').getElement().value = '';
        objHelper.clearResults(objComponent,'');
        objComponent.find('search-icon').getElement().classList.remove("slds-hide");
        objComponent.find('close-icon').getElement().classList.add("slds-hide");
        objComponent.find('enter-search').getElement().focus();
    },
    
    redirectTo : function(objComponent, objEvent, objHelper) {
        var strRecordId = null;
        var objFiredEvent = null;
        objHelper.clearResults(objComponent);   
        if(objEvent.currentTarget !== undefined && objEvent.currentTarget !== null && objEvent.currentTarget.dataset !== undefined && objEvent.currentTarget !== null) {
            strRecordId = objEvent.currentTarget.dataset.id;
            var recordType = objEvent.currentTarget.dataset.type;
            if(strRecordId !== undefined && strRecordId !== null && strRecordId.length > 0) {
                
                var searchEvent = $A.get("e.c:SearchEvent");
                searchEvent.setParams({searchType: recordType});
                searchEvent.fire();
                
                objFiredEvent = $A.get("e.force:navigateToSObject");
                objFiredEvent.setParams({
                    "recordId": strRecordId,
                    "slideDevName": "related"
                });
                objFiredEvent.fire();
                objFiredEvent.stopPropagation();
                objEvent.stopPropagation();
            }
        }
    }
})