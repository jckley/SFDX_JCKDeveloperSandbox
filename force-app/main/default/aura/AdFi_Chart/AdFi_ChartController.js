({
    initializeComponent : function(objComponent, objEvent, objHelper) {
        if(objHelper.isLoadedInit === false) {
            objHelper.isLoadedInit = true;
            objHelper.refreshChart(objComponent);
            objHelper.updateChart(objComponent);
        }
	},
    updateChart : function(component, event, helper) {
        var territoryId = component.get('v.recordId');
        helper.refreshChart(component, territoryId);
    }
})