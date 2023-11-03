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
        
        var objTerritory = objComponent.get('v.territoryWrapper');
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
            
            
        } else if (objTerritory !== undefined && objTerritory !== null){
            
            objCoordinate = {};
            objCoordinate.ViewExactLocation = boolViewExactLocation;
            objCoordinate.Address = [];
            objCoordinate.Address[1] = objTerritory.ter4.Name;
            objCoordinate.Address[2] = objTerritory.ter3.Name;
            objCoordinate.Address[3] = objTerritory.ter2.Name;
            objCoordinate.Address[4] = objTerritory.ter1.Name;
            
            objCoordinate.Latitude = (objCoordinate.Latitude !== '')?parseFloat(objCoordinate.Latitude):null;
            objCoordinate.Longitude = (objCoordinate.Longitude !== '')?parseFloat(objCoordinate.Longitude):null;
            
           
        }
        return objCoordinate;    
    }
})