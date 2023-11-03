({
	goToPlane : function(objComponent, objEvent, objHelper) {
        var strData = null;
        var strUrl = null;
        var objCitizen = null;

        if(objEvent !== undefined && objEvent !== null && objEvent.currentTarget !== undefined && objEvent.currentTarget !== null && objEvent.currentTarget.dataset !== undefined && objEvent.currentTarget.dataset !== null && objEvent.currentTarget.dataset.searchid !== undefined && objEvent.currentTarget.dataset.searchid !== null && objEvent.currentTarget.dataset.searchid.length > 0) {
            objCitizen = objComponent.get('v.citizenWrapper');

            if(objCitizen.citizen.mig_outbound_crossing_type__c !== undefined && objCitizen.citizen.mig_outbound_crossing_type__c !== null)  {
                strData = objEvent.currentTarget.dataset.searchid;
                strUrl = '/global-search/' + encodeURIComponent(strData)
    
                objEvent = $A.get("e.force:navigateToURL");
                objEvent.setParams({
                  "url": strUrl
                });
    
                objEvent.fire();                
            }
        }
    }
})