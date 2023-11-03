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
    },
    retrieveMapCoordinate : function(objComponent) {
        var objCoordinate = null;
        var objContact = null;
        var boolViewExactLocation = null;
        objContact = objComponent.get('v.citizenWrapper');
        boolViewExactLocation = objComponent.get('v.viewExactLocation');
        
        if(objContact !== undefined && objContact !== null && objContact.citizen !== undefined && objContact.citizen !== null) {            
            objCoordinate = {};
            objCoordinate.ViewExactLocation = boolViewExactLocation;
            objCoordinate.Latitude = objContact.citizen.MailingLatitude;
            objCoordinate.Longitude = objContact.citizen.MailingLongitude;
            objCoordinate.Address = [];
            objCoordinate.Address[0] = objContact.citizen.MailingStreet + ' ' + objContact.citizen.MailingNumber__c;
            objCoordinate.Address[1] = objContact.citizen.Level4Name__c;
            objCoordinate.Address[2] = objContact.citizen.Level3Name__c;
            objCoordinate.Address[3] = objContact.citizen.Level2Name__c;
            objCoordinate.Address[4] = objContact.citizen.Level1Name__c;
            
            objCoordinate.Latitude = (objCoordinate.Latitude !== '')?parseFloat(objCoordinate.Latitude):null;
            objCoordinate.Longitude = (objCoordinate.Longitude !== '')?parseFloat(objCoordinate.Longitude):null;
            objCoordinate.Google = {};
            objCoordinate.Google.lat = objCoordinate.Latitude;
            objCoordinate.Google.lng = objCoordinate.Longitude;
            objCoordinate.Google.center = {};
            objCoordinate.Google.center.lat = objCoordinate.Latitude;
            objCoordinate.Google.center.lng = objCoordinate.Longitude;
        }
        return objCoordinate;    
	},
    handleStreetViewEventLoaded : function(objComponent, boolIsLoaded) {
        objComponent.set('v.loaded', boolIsLoaded);		
    }    
})