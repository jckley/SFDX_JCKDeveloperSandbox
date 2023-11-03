({
	initializeComponent : function(objComponent, objEvent, objHelper) {
		var objCoordinate = null;

        //objCoordinate = objHelper.retrieveMapCoordinate(objComponent);
        //objHelper.centerMapWithAddress(objComponent, objCoordinate);
        //objHelper.showStreetViewPOV(objComponent, objCoordinate);
	},
    toggleStreetViewVisibility : function(objComponent, objEvent, objHelper) {
		var boolStreetViewLoaded = false;
        
        boolStreetViewLoaded = objEvent.getParam('loaded');
        
        objComponent.set('v.streetViewLoaded',boolStreetViewLoaded);
	}
})