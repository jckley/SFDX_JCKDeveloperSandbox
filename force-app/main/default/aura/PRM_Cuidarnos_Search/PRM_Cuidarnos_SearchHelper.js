({
    retrieveCitizenCount : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var intCount = null;
       
        objControllerAction = objComponent.get("c.retrieveCitizens"); 
        
        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            if (objComponent.isValid() && strState === "SUCCESS") {
                intCount = objResponse.getReturnValue();
                
                console.log('Citizen count : '+ intCount);

                objComponent.set('v.citizencount', intCount );
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
    },
    searchCitizens : function(objComponent, strSearchTerm, intRecordCount) {
        var objControllerAction = null;
        var strState = null;
        var arrResults = null;
        var strUrl = null;
        var objEvent = null;
        if(strSearchTerm !== undefined && strSearchTerm !== null && strSearchTerm.length > 0 ) {
            strUrl = '/global-search/' + encodeURIComponent(strSearchTerm)

            objEvent = $A.get("e.force:navigateToURL");
            objEvent.setParams({
              "url": strUrl
            });

            objEvent.fire();

            //https://comunidad.cuidarnos.com/s/global-search/rodriguez%20llanos
            /*
            objControllerAction = objComponent.get("c.searchCitizen"); 
            objControllerAction.setParams( {
                'strSearch': strSearchTerm,
                'intResults': intRecordCount
            });

            objControllerAction.setCallback(this, function(objResponse) {
                strState = objResponse.getState();
                if (objComponent.isValid() && strState === "SUCCESS") {
                    arrResults = objResponse.getReturnValue();
                
                    objComponent.set('v.results', JSON.parse(arrResults));
                } 
            });
            
            $A.enqueueAction(objControllerAction); 
            */
        } else {
            objComponent.set('v.results', null);
        }
	}
})