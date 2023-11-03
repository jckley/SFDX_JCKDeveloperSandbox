({
	initializeComponent : function(objComponent, objEvent, objHelper) {
        var strCitizenId = null;
        
        strCitizenId = objComponent.get('v.recordId');
		objHelper.retrieveCitizenInfo(objComponent, strCitizenId);
        objHelper.retrieveUserPermissions(objComponent);
        objHelper.retrieveBaseUrl(objComponent);

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
                case 'save_vota_a':
                    objHelper.saveVotoSF(objComponent);
                    var select = document.querySelector("#select-01");
                    select.setAttribute("data-original", select.value);
                    document.querySelector("#boton-guardar").setAttribute("disabled", "true");
                    break;
                case 'select-change':
                    console.log("select changed captured");
                    console.log(objEvent.currentTarget);
                    
                    var original_value = document.querySelector("#select-01").getAttribute("data-original");
                    console.log(original_value);
                    
                    var current_value = document.querySelector("#select-01").value;
                    console.log(current_value);

                    if (current_value == original_value) {
                        document.querySelector("#boton-guardar").setAttribute("disabled", "true");
                    } else {
                        document.querySelector("#boton-guardar").removeAttribute("disabled");
                    }

                    break;
               
            }
        }
    },
    closeModal : function(objComponent, objEvent, objHelper) {
        objHelper.hideModals(objComponent);
    },
})