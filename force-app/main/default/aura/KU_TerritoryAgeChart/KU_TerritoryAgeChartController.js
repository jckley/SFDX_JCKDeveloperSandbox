({
    updateChart : function(component, event, helper) {
        var territoryId = component.get('v.recordId');
        helper.refreshChart(component, territoryId);
    }
})