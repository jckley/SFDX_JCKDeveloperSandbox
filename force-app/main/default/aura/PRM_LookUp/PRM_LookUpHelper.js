({
	searchRecordsHelper : function(component, event, helper, value) {
		$A.util.removeClass(component.find("Spinner"), "slds-hide");
        var searchString = component.get('v.searchString');
        component.set('v.message', '');
        component.set('v.recordsList', []);
		// Calling Apex Method
    	var action = component.get('c.fetchRecords');
        action.setParams({
            'strObject' : component.get('v.objectName'),
            'strField' : component.get('v.fieldName'),
            'strSearchString' : searchString,
            'strCode' : value
        });
        action.setCallback(this,function(response){
        	var result = response.getReturnValue();
        	if(response.getState() === 'SUCCESS') {
    			if(result.length > 0) {
    				// To check if value attribute is prepopulated or not
					if( $A.util.isEmpty(value) ) {
                        component.set('v.recordsList',result);        
					} else {
                        component.set('v.selectedRecord', result[0]);
					}
    			} else {
    				component.set('v.message', "No se encontraron registros para '" + searchString + "'");
    			}
        	} else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            // To open the drop down list of records
            if( $A.util.isEmpty(value) )
                $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        	$A.util.addClass(component.find("Spinner"), "slds-hide");
        });
        $A.enqueueAction(action);
	}
})
/*
 Code by CafeForce
 Website: http://www.cafeforce.com
 DO NOT REMOVE THIS HEADER/FOOTER FOR FREE CODE USAGE
*/