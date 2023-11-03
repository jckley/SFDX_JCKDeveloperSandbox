({
    navigateToRecord : function(component, event, helper) {
        var eventFired = null;
        var recordId = null;
        recordId = component.get("v.linkToRecordId");
        if(recordId != '#') {
            if(recordId.indexOf('/') >= 0) {
                eventFired = $A.get("e.force:navigateToURL");
                eventFired.setParams({
                    "url": recordId
                });
            } else {
                eventFired = $A.get("e.force:navigateToSObject");
                eventFired.setParams({
                    "recordId": recordId
                });
            }
            eventFired.fire();        
            eventFired.stopPropagation();
        }
    },
    proccesAction : function(objComponent, objEvent, objHelper) {      
        var strAction = null;

        if(objEvent !== undefined && objEvent !== null && objEvent.currentTarget !== undefined && objEvent.currentTarget !== null && objEvent.currentTarget.dataset !== undefined && objEvent.currentTarget.dataset !== null && objEvent.currentTarget.dataset.action !== undefined && objEvent.currentTarget.dataset.action !== null && objEvent.currentTarget.dataset.action.length > 0) {
            strAction = objEvent.currentTarget.dataset.action;
            switch(strAction) {
                case 'edit':
                    objHelper.showModal(objComponent, 'divModalEdit');
                    break;  
                case 'save_edit':
                    objHelper.saveCitizenSF(objComponent);
                    objHelper.hideModals(objComponent);
                    break;
                case 'close_modal':
                    objHelper.hideModals(objComponent);
                    break;
               
            }
        }
    },
    fireHierarchyEvent : function(component, event, helper) {
        var eventFired = null;
        var recordId = null;
        var adminLevel = null;
        recordId = component.get("v.territoryWrapper.territory.Id");
        adminLevel = component.get("v.territoryWrapper.territory.Nivel_Administrativo__c");
        
        eventFired = component.getEvent("mainHeaderClickEvent");
        eventFired.setParams({
            "recordId" : recordId,
            "adminLevel" : adminLevel
        });
		eventFired.fire();
    },
    closeModal : function(objComponent, objEvent, objHelper) {
        objHelper.hideModals(objComponent);
    },
    goToRelated : function(objComponent, objEvent, objHelper) {
        var strData = null;
        var strUrl = null;

        if(objEvent !== undefined && objEvent !== null && objEvent.currentTarget !== undefined && objEvent.currentTarget !== null && objEvent.currentTarget.dataset !== undefined && objEvent.currentTarget.dataset !== null && objEvent.currentTarget.dataset.search !== undefined && objEvent.currentTarget.dataset.search !== null && objEvent.currentTarget.dataset.search.length > 0) {
            strData = objEvent.currentTarget.dataset.search;

            strUrl = '/global-search/' + encodeURIComponent(strData)

            objEvent = $A.get("e.force:navigateToURL");
            objEvent.setParams({
              "url": strUrl
            });

            objEvent.fire();
        }
    }
})