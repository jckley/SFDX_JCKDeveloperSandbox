({
	initializeComponent : function(objComponent, objEvent, objHelper) {
        window.addEventListener("message", function(objEvent) {
            if(objEvent.data.state == 'LOADED') {
                objHelper.sendToVF(objComponent);
            }
        }, false);
	}
})