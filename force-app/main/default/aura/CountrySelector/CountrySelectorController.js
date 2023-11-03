({
	initializeComponent : function(objComponent, objEvent, objHelper) {
		objHelper.retrieveTerritories(objComponent);
    },    
    updateUserRole : function(objComponent, objEvent, objHelper) {
		objHelper.updateUserRoleInSF(objComponent, objComponent.get('v.selectedValue'));
    }
})