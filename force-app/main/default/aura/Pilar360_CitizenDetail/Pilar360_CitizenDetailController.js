({
	initializeComponent : function(objComponent, objEvent, objHelper) {
        var strCitizenId = null;
        var intTotalInteractions = 0;
        
        strCitizenId = objComponent.get('v.recordId');
		objHelper.retrieveCitizenInfo(objComponent, strCitizenId);
        objHelper.retrieveUserPermissions(objComponent);
        objHelper.retrieveBaseUrl(objComponent);
        if(objComponent.get('v.makelog')){
            objHelper.makeLog(objComponent);
        }
        


        // console.log('retrieveInteracions In connectedCallback()...');
        // retrieveInteractions({'id' : this.citizenid})
        //     .then(result => {
        //         result.forEach(res => {
        //             console.log('interactions resul: ' + res.Programs__c);
        //             intTotalInteractions += 1;
        //         });
        //     })
        //     .catch(error => {
        //         error = error;
        //     });

        //Get the event using event name. 
        var appEvent = $A.get("e.c:PRMCommunityEvent"); 
        //Set event attribute value
        appEvent.setParams({"message" : "CitizenDetail"}); 
        appEvent.fire();

	},
    
    refreshPage : function(objComponent, objEvent, objHelper) {
        $A.get('e.force:refreshView').fire();
    },
    proccesAction : function(objComponent, objEvent, objHelper) {      
        var strAction = null;

        if(objEvent !== undefined && objEvent !== null && objEvent.currentTarget !== undefined && objEvent.currentTarget !== null && objEvent.currentTarget.dataset !== undefined && objEvent.currentTarget.dataset !== null && objEvent.currentTarget.dataset.action !== undefined && objEvent.currentTarget.dataset.action !== null && objEvent.currentTarget.dataset.action.length > 0) {
            strAction = objEvent.currentTarget.dataset.action;
            switch(strAction) {
                case 'edit':
                    objHelper.showModal(objComponent, 'divModalEdit');
                    break;  
                case 'save_edit':
                    objHelper.saveCitizenSF(objComponent);
                    objHelper.hideModals(objComponent);
                    break;
                case 'close_modal':
                    objHelper.hideModals(objComponent);
                    break;
               
            }
        }
    },
    closeModal : function(objComponent, objEvent, objHelper) {
        objHelper.hideModals(objComponent);
    },
})