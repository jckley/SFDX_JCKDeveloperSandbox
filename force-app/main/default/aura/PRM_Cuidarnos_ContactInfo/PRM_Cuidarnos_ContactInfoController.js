({
    updateEditInfo : function(objComponent, objEvent, objHelper) {
        var strEmail = null;
        var strMobile = null;

        strEmail = objEvent.get('email');
        strMobile = objEvent.get('mobile');
        
        objComponent.set('v.email', strEmail);
        objComponent.set('v.mobile', strMobile);
    },

    showTelemedicoModal : function(objComponent, objEvent, objHelper) {
        var objFiredEvent = null;

        objFiredEvent = $A.get("e.c:Cuidarnos_Telemedico_Event");
        objFiredEvent.fire();  
    },
    notifyUser: function(objComponent, objEvent, objHelper) {
        objHelper.notify(objComponent);
    } 
})