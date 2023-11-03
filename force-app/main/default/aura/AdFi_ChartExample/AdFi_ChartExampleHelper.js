({
	retrieveChartData : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var strJSONChartData = null;
        var objThat = this;
        var objJSON = null;
         
        console.log('[AdFi_ChartExampleHelper]retrieveChartData ->');
        
        objControllerAction = objComponent.get("c.retrieveChartDataExample"); 
        objControllerAction.setParams( {
            'intCategoryCount': 5,
            'intDatasetCount': 3
        });
        
        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            
            if (objComponent.isValid() && strState === "SUCCESS") {
                strJSONChartData = objResponse.getReturnValue();
                
                objComponent.set('v.chartData', strJSONChartData);
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
        
        console.log('[AdFi_ChartExampleHelper]retrieveChartData <-');
		
	}
})