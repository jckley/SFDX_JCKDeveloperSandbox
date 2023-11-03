({
    refreshStatus : function(objComponent, objEvent, objHelper) {
        var objCitizenWrapper = null;
        
        objCitizenWrapper = objComponent.get('v.citizenWrapper');
        objHelper.retrieveCitizenInfo(objComponent, objCitizenWrapper.citizen.Id);
        
    },
    proccesAction : function(objComponent, objEvent, objHelper) {      
        var strAction = null;
        var objFiredEvent = null;
        if(objEvent !== undefined && objEvent !== null && objEvent.currentTarget !== undefined && objEvent.currentTarget !== null && objEvent.currentTarget.dataset !== undefined && objEvent.currentTarget.dataset !== null && objEvent.currentTarget.dataset.action !== undefined && objEvent.currentTarget.dataset.action !== null && objEvent.currentTarget.dataset.action.length > 0) {
            strAction = objEvent.currentTarget.dataset.action;
            switch(strAction) {
                case 'viewhistory':
                    objFiredEvent = $A.get('e.c:PRM_Cuidarnos_ShowHistory_Event')
                    objFiredEvent.fire();                    
                    break;  
                case 'close_modal':
                    objHelper.hideModals(objComponent);
                    break;               
            }
        }
    },
    closeModal : function(objComponent, objEvent, objHelper) {
        objHelper.hideModals(objComponent);
    },
    
})