({
	initializeComponent : function(objComponent, objEvent, objHelper) {
		objHelper.retrieveAvailableCountries(objComponent);
	},
    handleChangeCountry : function(objComponent, objEvent, objHelper) {
        var strGroupName = null;

        strGroupName = objEvent.currentTarget.dataset.group;

		objHelper.changeCountry(objComponent, strGroupName);
	}
})