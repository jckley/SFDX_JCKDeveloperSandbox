({
	initializeComponent : function(objComponent, objEvent, objHelper) {
        var objFiredEvent = null;
        
        objComponent.set('v.lexHost', window.location.hostname);
                      
        window.addEventListener("message", function(objEvent) {
            if(objEvent.data.state === 'LOADED') {
                objHelper.sendToVF(objComponent);
            } else if(objEvent.data.state === 'OK') {
                objHelper.handleStreetViewEventLoaded(objComponent, true);
            } else if(objEvent.data.state === 'FAILED') { 
                objHelper.handleStreetViewEventLoaded(objComponent, false);
            }
        }, false);
	}
})