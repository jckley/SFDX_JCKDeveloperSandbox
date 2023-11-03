({
    initializeComponent : function(objComponent, objEvent, objHelper) {
        objHelper.retrieveCitizenCount(objComponent);
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
    }

})