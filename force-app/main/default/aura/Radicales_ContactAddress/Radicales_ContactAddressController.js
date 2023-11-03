({
    updateEditInfo : function(objComponent, objEvent, objHelper) {
        var strFijo = null;

        strFijo = objEvent.getParam('fijo');
        
        objComponent.set('v.fijo', strFijo);
    },
})