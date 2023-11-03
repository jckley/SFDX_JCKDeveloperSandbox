({
    retrieveContactLayout : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var objLayout = null;
        
        objControllerAction = objComponent.get("c.retrieveLayout"); 
        
        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();

            if (objComponent.isValid() && strState === "SUCCESS") {
                objLayout = JSON.parse(objResponse.getReturnValue());
                
                objComponent.set('v.layout', objLayout);
            } 
        });
        
        $A.enqueueAction(objControllerAction);         
	},
    showModal : function(objComponent) {
        var divModal = null;
        var divBackground = null;
                
        divModal = objComponent.find('divModal');
        divBackground = objComponent.find('divBackground');
        
        if(divModal !== undefined && divModal !== null && divBackground !== undefined && divBackground !== null) {
            if(!$A.util.hasClass(divModal, 'slds-fade-in-open')) {
                $A.util.addClass(divModal, 'slds-fade-in-open');
            }
            
            if(!$A.util.hasClass(divBackground, 'slds-backdrop_open')) {
                $A.util.addClass(divBackground, 'slds-backdrop_open');
            }
            
            if($A.util.hasClass(divModal, 'slds-hide')) {
                $A.util.removeClass(divModal, 'slds-hide');
            }
        }
    },
    hideModal : function(objComponent) {
        var divModal = null;
        var divBackground = null;
                
        divModal = objComponent.find('divModal');
        divBackground = objComponent.find('divBackground');
        
        if(divModal !== undefined && divModal !== null && divBackground !== undefined && divBackground !== null) {
            if($A.util.hasClass(divModal, 'slds-fade-in-open')) {
                $A.util.removeClass(divModal, 'slds-fade-in-open');
            }
            
            if($A.util.hasClass(divBackground, 'slds-backdrop_open')) {
                $A.util.removeClass(divBackground, 'slds-backdrop_open');
            }
            
            if(!$A.util.hasClass(divModal, 'slds-hide')) {
                $A.util.addClass(divModal, 'slds-hide');
            }
        }
    }
})