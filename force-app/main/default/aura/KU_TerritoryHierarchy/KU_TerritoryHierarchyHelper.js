({
    DEBUG : false,
    retrieveRootTerritory : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var objTerritory = null;
        var objThat = this;
        
        this.DEBUG && console.log('[TerritoryHierarchyController]retrieveRootTerritory ->');
        
        objControllerAction = objComponent.get("c.retrieveParentTerritory"); 
        
        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            
            if (objComponent.isValid() && strState === "SUCCESS") {
                objTerritory = objResponse.getReturnValue();
                objComponent.set('v.rootTerritory', objTerritory);
                
                objThat.retrieveTerritoriesFromSalesforce(objComponent, objTerritory.Id, objTerritory.Level);
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
        
        this.DEBUG && console.log('[TerritoryHierarchyController]retrieveRootTerritory <-');
    },
    retrieveTerritoriesFromSalesforce : function(objComponent, strTerritoryId, intLevel) {
        var objControllerAction = null;
        var strState = null;
        var arrTerritories = null;
        var objEvent = null;
        var objThat = this;
        
        this.DEBUG && console.log('[TerritoryHierarchyController]retrieveTerritoriesFromSalesforce [ strTerritoryId : ' + strTerritoryId + ' - intLevel : ' + intLevel + ' ]->');
        
        objControllerAction = objComponent.get("c.retrieveTerritoriesByParent"); 
        objControllerAction.setParams( {
            'strParentId': strTerritoryId
        });
        
        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            
            if (objComponent.isValid() && strState === "SUCCESS") {
                arrTerritories = objResponse.getReturnValue();
                
                this.DEBUG && console.log('[TerritoryHierarchyController]retrieveTerritoriesFromSalesforce [ firing TerritoryHierarchyRetrievedEvent intLevel : ' + intLevel + ' ]->');
                
                objEvent = $A.get("e.c:TerritoryHierarchyRetrievedEvent");
                objEvent.setParam('level', parseInt(intLevel));
                objEvent.setParam('territories', arrTerritories);                   
                objEvent.fire();
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
        this.DEBUG && console.log('[TerritoryHierarchyController]retrieveTerritoriesFromSalesforce <-');
    },
    saveSelectedTerritory : function(objComponent, strTerritoryId) {
        var objControllerAction = null;
        var strState = null;
        var arrTerritory = null;
        var strSelectedTerritory = null;
        var objThat = this;
        
        this.DEBUG && console.log('[TerritoryHierarchyController]saveSelectedTerritory [ ' + strTerritoryId + ' ] ->');
        
        if(strTerritoryId !== undefined && strTerritoryId !== null && strTerritoryId.length > 0 ) {
            objControllerAction = objComponent.get("c.saveLastSelectedTerritory"); 
            objControllerAction.setParams({
                'strTerritoryId' : strTerritoryId
            });
            
            $A.enqueueAction(objControllerAction); 
        } 
        
        this.DEBUG && console.log('[TerritoryHierarchyController]saveSelectedTerritory <-');
    },
    clearSelectedTerritory : function(objComponent) {
        var objControllerAction = null;
        
        this.DEBUG && console.log('[TerritoryHierarchyController]clearSelectedTerritory [] ->');

        objControllerAction = objComponent.get("c.clearLastSelectedTerritory"); 
        $A.enqueueAction(objControllerAction); 
        
        this.DEBUG && console.log('[TerritoryHierarchyController]clearSelectedTerritory <-');     
	}
})