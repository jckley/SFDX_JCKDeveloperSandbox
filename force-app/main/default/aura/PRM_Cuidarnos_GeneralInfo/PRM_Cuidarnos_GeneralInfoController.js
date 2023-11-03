({
	redirectToEditPage : function(component, event, helper) {        
        var objEvent = null;
        
        objEvent = $A.get("e.c:ShowContactEditionEvent");

        objEvent.fire();
	}
})