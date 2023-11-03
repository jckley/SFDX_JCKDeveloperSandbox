({
	openEditionModal : function(objComponent, objEvent, objHelper) {
        var objEvent = null;
		
        objEvent = $A.get('e.c:ShowContactEditionEvent');
        objEvent.fire();
	}
})