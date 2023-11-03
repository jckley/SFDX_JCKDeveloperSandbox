({
    retrieveCitizenCount : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var intCount = null;
       
        objControllerAction = objComponent.get("c.retrieveRiverIDCitizens"); 
        
        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            if (objComponent.isValid() && strState === "SUCCESS") {
                let integerCitizens = parseInt(objResponse.getReturnValue())
                intCount = integerCitizens.toLocaleString('de-DE');
                // console.log('Citizen count : '+ intCount);

                // agrego los puntos a intCount
                // intCount = intCount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
                // console.log('Citizen count with dots: '+ intCount);

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
    },
    retrieveResults : function(objComponent, strSearch) {
        var objControllerAction = null;
        var strState = null;
        var arrResults = null;
        var objThat = this;         
        
        objControllerAction = objComponent.get("c.searchForNames"); 
        objControllerAction.setParams( {
            'strSearch': strSearch
        });
        
        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            
            if (objComponent.isValid() && strState === "SUCCESS") {
                arrResults = objResponse.getReturnValue();
                // console.log('results: ');
                // console.log(arrResults);
                
                objComponent.set('v.results', JSON.parse(arrResults));
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
        
	},
    clearResults : function(objComponent, strSearch) { 
        objComponent.set('v.results', null);
    }
})