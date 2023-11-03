({
	redirectToEditPage : function(component, event, helper) {
        
        var objEvent = $A.get("e.c:ShowContactEditionEvent");
        objEvent.fire();
	}
})