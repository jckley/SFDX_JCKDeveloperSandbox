({
    initializeComponent : function(objComponent, objEvent, objHelper) {
        console.log('[AdFi_ChartExampleController]initializeComponent ->');
        
        objHelper.retrieveChartData(objComponent);
        
        console.log('[AdFi_ChartExampleController]initializeComponent <-');
    }
})