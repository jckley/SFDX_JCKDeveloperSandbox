({
    sendToVF : function(objComponent) {        
        var objCoordinate = null;
        
        objCoordinate = this.retrieveMapCoordinate(objComponent);
        
        this.sendMessage(objComponent, objCoordinate);
    },
    sendMessage: function(objComponent, objCoordinate){
        var objIframe = null;
        
        objCoordinate.origin = objComponent.get('v.lexHost');
        
        objIframe = objComponent.find("vfFrame").getElement().contentWindow;
        objIframe.postMessage(JSON.stringify(objCoordinate), objComponent.get("v.vfHost"));
    }
})