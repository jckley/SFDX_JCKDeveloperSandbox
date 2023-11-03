({
    updateEditInfo : function(objComponent, objEvent, objHelper) {
        var strEmail = null;
        var strMobile = null;

        strEmail = objEvent.getParam('email');
        strMobile = objEvent.getParam('mobile');
        
        objComponent.set('v.email', strEmail);
        objComponent.set('v.mobile', strMobile);
    },
})