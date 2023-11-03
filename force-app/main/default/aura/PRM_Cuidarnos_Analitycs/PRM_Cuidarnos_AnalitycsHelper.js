({
    retrieveDashboardFromSalesforce : function(objComponent) {
        var objControllerAction = null;
        var strState = null;
        var strDashboardId = null;
        var strDashboardType = null;
        
        strDashboardType = objComponent.get('v.dashboardtype');

        objControllerAction = objComponent.get("c.retrieveDashboardId"); 
        objControllerAction.setParams({
            "strDashboardType" : strDashboardType
        });

        objControllerAction.setCallback(this, function(objResponse) {
            strState = objResponse.getState();
            if (objComponent.isValid() && strState === "SUCCESS") {
                strDashboardId = objResponse.getReturnValue();
                
                objComponent.set('v.dashboardId', strDashboardId);
            } 
        });
        
        $A.enqueueAction(objControllerAction); 
	}
})