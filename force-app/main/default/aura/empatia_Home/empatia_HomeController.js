({
    initializeComponent : function(objComponent, objEvent, objHelper) {
        console.log('Iniciando HOME')
    },
    perfomrSearch : function(objComponent, objEvent, objHelper) {
        var intLimit = null;
        var strSearchTearm = null;

        if (objEvent.which === 13){
            strSearchTearm = objComponent.get('v.searchTerm');
            intLimit = objComponent.get('v.querylimit');

            //Get the event using event name. 
            var appEvent = $A.get("e.c:PRMCommunityEvent"); 
            //Set event attribute value
            appEvent.setParams({"message" : "CitizenSearch"}); 
            appEvent.fire(); 

            objHelper.searchCitizens(objComponent, strSearchTearm, intLimit );    
        }   
    },
    redirectToRecord : function(objComponent, objEvent, objHelper) {
        var strRecordId = null;
        var objFiredEvent = null;
        if(objEvent.currentTarget !== undefined && objEvent.currentTarget !== null && objEvent.currentTarget.dataset !== undefined && objEvent.currentTarget !== null) {
            strRecordId = objEvent.currentTarget.dataset.id; 
            
            objFiredEvent = $A.get("e.force:navigateToSObject");
            objFiredEvent.setParams({
                "recordId": strRecordId,
                "slideDevName": "related"
            });

            objFiredEvent.fire();
            objFiredEvent.stopPropagation();
            objEvent.stopPropagation();
        }
    },
    doInit : function(cmp, event,helper) { 
        //Get the event using event name. 
        var appEvent = $A.get("e.c:PRMCommunityEvent"); 
        //Set event attribute value
        appEvent.setParams({"message" : "Home"}); 
        appEvent.fire(); 
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
        strSearchText = objComponent.find('enter-search').getElement().value;
        
        objComponent.find('search-text').getElement().classList.remove("slds-hide");
        objComponent.find('search-icon-focus').getElement().classList.remove("slds-hide");
        objComponent.find('search-icon').getElement().classList.add("slds-hide");
        
        if(strSearchText != '') {
            objComponent.find('guide').getElement().classList.remove("slds-hide");
            // objComponent.find('search-icon').getElement().classList.remove("slds-hide");
            objComponent.find('close-icon').getElement().classList.add("slds-hide");
        } else {
            objComponent.find('guide').getElement().classList.add("slds-hide");
        }
    },
    onBlur : function (objComponent, objEvent, objHelper) {
        var strSearchText = null;

        if(objComponent.find('search-container').getElement()){
            objComponent.find('guide').getElement().classList.add("slds-hide");
            objComponent.find('search-text').getElement().classList.add("slds-hide");
            objComponent.find('search-icon-focus').getElement().classList.add("slds-hide");
            objComponent.find('search-icon').getElement().classList.remove("slds-hide");
            strSearchText = objComponent.find('enter-search').getElement().value;
            
            if(strSearchText != ''){
                objComponent.find('search-icon').getElement().classList.add("slds-hide");
                objComponent.find('close-icon').getElement().classList.remove("slds-hide");
            }
            
            setTimeout( function(){
                objHelper.clearResults(objComponent)
            }, 500);
            objEvent.stopPropagation();
        }
        
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
    },

    handleQueryData: function (component, event) {
        try {
            let queryResult = event.bp.results.records[0].count;
            component.set('v.citizencount',queryResult.toLocaleString('en-US').replace(',','.'));
        } catch (e) {
            console.log('no se pudo obtener info de analytics');
            component.set('v.citizencount',0);
        }
        
    }

})