({        
    initializeComponent : function(objComponent, objEvent, objHelper) {
        var strSearchText = null;
        const page = window.location.href.substring(window.location.href.indexOf('/s/'));
        // console.log('DAC ---> page: ', page);
        // console.log('page: ', page);
        if(window.location.href.indexOf('global-search') >= 0 ) {
            objComponent.set('v.rendered', true);
            strSearchText = window.location.href.substring(window.location.href.indexOf('global-search') + 'global-search'.length + 1);
            strSearchText = decodeURIComponent(strSearchText);
            // console.log('strSearchText: ', strSearchText);
            objComponent.set('v.searchText', strSearchText);
        } else if(page === '/s/' || page.includes('territories')) {
            objComponent.set('v.rendered', false);
        } else if(page.includes('territorio-administrativo')) {
            objComponent.set('v.searchText', "");
            objComponent.set('v.rendered', true); 
        } else if(page.indexOf("contact") > 0) {
            objComponent.set('v.searchText', "");
            objComponent.set('v.rendered', true); 
        } else if(page.includes('iframe')) {
            objComponent.set('v.rendered', false);
        } else {
            objComponent.set('v.rendered', true); 
        }
    },
    searchText : function(objComponent, objEvent, objHelper) {
        var strSearchText = null;
        var objSearchEvent = null;
        var objNavigateEvent = null;

        strSearchText = objComponent.find('enter-search').getElement().value;
        objComponent.set('v.searchText',strSearchText);

        if(strSearchText == ''){
            objComponent.find('guide').getElement().classList.add("slds-hide");
        } else {
            objComponent.find('guide').getElement().classList.remove("slds-hide");
        }

        if (objEvent.keyCode === 13) {
            objSearchEvent = $A.get("e.c:SearchEvent");
            objSearchEvent.setParams({searchType: ''});
            objSearchEvent.fire();

            objHelper.clearResults(objComponent,'');
            
            objNavigateEvent = $A.get('e.force:navigateToURL');
            objNavigateEvent.setParams({url: '/global-search/' + encodeURIComponent(strSearchText)});
            objNavigateEvent.fire();
        } else {
            if(strSearchText !== undefined && strSearchText !== null && strSearchText.length > 0) {
                objHelper.retrieveResults(objComponent, strSearchText);            
            } else {
                objHelper.clearResults(objComponent);            
            }
        }
    },
    onFocus : function (objComponent, objEvent, objHelper) {
        var strSearchText = null;
        
        objComponent.find('guide').getElement().classList.remove("slds-hide");
        objComponent.find('search-icon-focus').getElement().classList.remove("slds-hide");
        // objComponent.find('search-icon').getElement().classList.add("slds-hide");
        objComponent.find('search-text').getElement().classList.remove("slds-hide");
        
        strSearchText = objComponent.find('enter-search').getElement().value;

        // objComponent.find('enter-search').getElement().placeholder = '';
        console.log('strSearchText:', strSearchText);
        if(strSearchText !== undefined && strSearchText !== null && strSearchText.length > 0 && strSearchText !== '') {
            objComponent.find('guide').getElement().classList.remove("slds-hide");
            // objComponent.find('search-icon').getElement().classList.remove("slds-hide");
            objComponent.find('close-icon').getElement().classList.add("slds-hide");
        } else {
            objComponent.find('guide').getElement().classList.add("slds-hide");
        }
    },
    onBlur : function (objComponent, objEvent, objHelper) {
        var strSearchText = null;
        
        objComponent.find('guide').getElement().classList.add("slds-hide");
        objComponent.find('search-icon-focus').getElement().classList.add("slds-hide");
        strSearchText = objComponent.find('enter-search').getElement().value;
        objComponent.find('search-text').getElement().classList.add("slds-hide");

        // objComponent.find('enter-search').getElement().placeholder = 'Buscar ciudadano';
        
        if(strSearchText != ''){
            // objComponent.find('search-icon').getElement().classList.add("slds-hide");
            objComponent.find('close-icon').getElement().classList.remove("slds-hide");
        }
        
        setTimeout( function(){
            objHelper.clearResults(objComponent)
        }, 500);
        objEvent.stopPropagation();
    },
    clearText : function (objComponent, objEvent, objHelper) {
        objComponent.find('enter-search').getElement().value = '';
        objHelper.clearResults(objComponent,'');
        // objComponent.find('search-icon').getElement().classList.remove("slds-hide");
        objComponent.find('close-icon').getElement().classList.add("slds-hide");
        objComponent.find('enter-search').getElement().focus();
        console.log("clearText!!!!!!!!!!!!!!!!!!!!!");
    },
    
    redirectTo : function(objComponent, objEvent, objHelper) {
        var strRecordId = null;
        var objFiredEvent = null;
        var objSearchEvent = null;
        var strRecordtype = null;
        
        objHelper.clearResults(objComponent);   
        
        if(objEvent.currentTarget !== undefined && objEvent.currentTarget !== null && objEvent.currentTarget.dataset !== undefined && objEvent.currentTarget !== null) {
            strRecordId = objEvent.currentTarget.dataset.id;
            strRecordtype = objEvent.currentTarget.dataset.type;
            if(strRecordId !== undefined && strRecordId !== null && strRecordId.length > 0) {                
                objSearchEvent = $A.get("e.c:SearchEvent");
                objSearchEvent.setParams({
                    searchType: strRecordtype
                });
                objSearchEvent.fire();
                
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