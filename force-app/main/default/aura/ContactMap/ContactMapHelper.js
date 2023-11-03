({
    Zoom : 17,
    Component : null,
	retrieveMapCoordinate : function(objComponent) {
        var objCoordinate = null;
        var objContact = null;
        
        objContact = objComponent.get('v.citizenWrapper');
        
        if(objContact !== undefined && objContact !== null && objContact.citizen !== undefined && objContact.citizen !== null) {
            objCoordinate = {};
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
    centerMapWithAddress : function(objComponent, objCoordinate, objThatAux) {
        var objGeocoder = null;
        var objMapSettings = null;
        var objThat = (objThatAux === undefined || objThatAux === null)?this:objThatAux;
        
        objGeocoder = new google.maps.Geocoder();
        objGeocoder.geocode({
            'address': objCoordinate.Address.join(',')
        }, function(arrResults, objStatus) {
            //PODRIA VALIDAR TAMBIEN QUE LAT Y LNG NO SEAN NULOS.
            if (objStatus == google.maps.GeocoderStatus.OK && arrResults.length > 0) {
                if(arrResults[0].geometry.location_type == 'APPROXIMATE') {
                    objThat.Zoom -= 2; //voy alejando el zoom a medida que no voy encontrando la locacion
                }
                objCoordinate.Latitude = arrResults[0].geometry.location.lat();
                objCoordinate.Longitude = arrResults[0].geometry.location.lng();
                objCoordinate.Google = {};
                objCoordinate.Google.lat = objCoordinate.Latitude;
                objCoordinate.Google.lng = objCoordinate.Longitude;
                objCoordinate.Google.center = {};
                objCoordinate.Google.center.lat = objCoordinate.Latitude;
                objCoordinate.Google.center.lng = objCoordinate.Longitude;
                
                objThat.centerMapWithCoordinate(objComponent, objCoordinate, objThat);                              
            } else {
                //si no devolvio la direccion, vuelvo a llamar a la funcion buscando por un nivel superior-
                //si no lo encuentro a la primera, debo ocultar el street view
                objThat.hideStreetView(objComponent);
                objThat.Zoom -= 2; //voy alejando el zoom a medida que no voy encontrando la locacion
             	objCoordinate.Address.shift();
                objThat.centerMapWithAddress(objComponent, objCoordinate, objThat);
            }
        }); 
    },
    centerMapWithCoordinate : function(objComponent, objCoordinate, objThat) {
        var objMapSettings = null;
        var objMapMarker = null;
        var boolViewExactLocation = null;
        
        objMapSettings = objThat.retrieveMapSettings(objCoordinate, objThat.Zoom);
        boolViewExactLocation = objComponent.get('v.viewExactLocation');
        objMap = new google.maps.Map(document.getElementById('divMap'),objMapSettings);
        
        if(boolViewExactLocation) {
            objMapMarker = new google.maps.Marker({
                position: objCoordinate.Google,
                map: objMap
            });
        }
    },
    showStreetViewPOV : function(objComponent, objCoordinate) {
        var objGeocoder = null;
        var objMapSettings = null;
        var objThat = this;
        
        objGeocoder = new google.maps.Geocoder();
        objGeocoder.geocode({
            'address': objCoordinate.Address.join(',')
        }, function(arrResults, objStatus) {
            //PODRIA VALIDAR TAMBIEN QUE LAT Y LNG NO SEAN NULOS.
            if (objStatus == google.maps.GeocoderStatus.OK && arrResults.length > 0 && arrResults[0].geometry.location_type != 'APPROXIMATE') {
                objCoordinate.Latitude = arrResults[0].geometry.location.lat();
                objCoordinate.Longitude = arrResults[0].geometry.location.lng();
                objCoordinate.Google = {};
                objCoordinate.Google.lat = objCoordinate.Latitude;
                objCoordinate.Google.lng = objCoordinate.Longitude;
                objCoordinate.Google.center = {};
                objCoordinate.Google.center.lat = objCoordinate.Latitude + 0.0017;
                objCoordinate.Google.center.lng = objCoordinate.Longitude;
                if(objCoordinate.Latitude != null && objCoordinate.Longitude != null ) {
                    objThat.showStreetView(objComponent, objCoordinate, objThat);    
                } else {
                    objThat.hideStreetView(objComponent);  
                }
            } else {
                objThat.hideStreetView(objComponent);             
            }
        });  
    },
    showStreetView : function (objComponent, objCoordinate, objThatAux) {
        var objStreetViewService = null;
        var objStreetViewSettings = null;
        
        objStreetViewSettings = objThatAux.retrieveStreetViewSetting();
        objStreetView = new google.maps.StreetViewPanorama(document.getElementById('divStreetView'), objStreetViewSettings);
        
        objStreetViewService = new google.maps.StreetViewService();
        objStreetViewService.getPanorama({location: objCoordinate.Google, radius: 50}, function(objData, strStatus) {
            if  (strStatus === 'OK') {  
                objStreetView.setPano(objData.location.pano);
                objComponent.set('v.streetViewLoaded', true);
            } else {
                objThatAux.hideStreeView(objComponent);
            }
        }                               );
    },
    hideStreetView : function(objComponent) {
        objComponent.set('v.streetViewLoaded', false);
    },
    retrieveStreetViewSetting : function () {
    	return {
                pov : { heading: 0, pitch: 0},
                zoom : 1,
                linksControl : false,
                panControl : false,
                fullScreenControl : false,
                enableCloseButton : false,
                motionTrackingControl : false,
            	scrollwheel : false
            };
    },
    retrieveMapSettings : function (objCoordinate, intZoom) {
        var objMapFeatures = null;
        
        objMapFeatures = {};
        objMapFeatures.zoom = (intZoom !== undefined && intZoom !== null && intZoom > 0 && intZoom < 18)?intZoom:14;
        objMapFeatures.center = objCoordinate.Google.center;
        objMapFeatures.zoomControl = true;
        objMapFeatures.mapTypeControl = false;
        objMapFeatures.scaleControl = false;
        objMapFeatures.streetViewControl = false;
        objMapFeatures.rotateControl = false;
        objMapFeatures.scrollwheel = false;
        objMapFeatures.fullscreenControl = false;
        
        objMapFeatures.styles = this.retrieveStyles();
        
        return objMapFeatures;
    },
    retrieveStyles : function() {
    	return [
                {
                    "featureType": "all",
                    "elementType": "labels",
                    "stylers": [
                        {
                            "visibility": "off"
                        }
                    ]
                },
                {
                    "featureType": "administrative",
                    "elementType": "all",
                    "stylers": [
                        {
                            "visibility": "simplified"
                        },
                        {
                            "color": "#5b6571"
                        },
                        {
                            "lightness": "35"
                        }
                    ]
                },
                {
                    "featureType": "administrative.neighborhood",
                    "elementType": "all",
                    "stylers": [
                        {
                            "visibility": "off"
                        }
                    ]
                },
                {
                    "featureType": "landscape",
                    "elementType": "all",
                    "stylers": [
                        {
                            "visibility": "on"
                        },
                        {
                            "color": "#f3f4f4"
                        }
                    ]
                },
                {
                    "featureType": "landscape.man_made",
                    "elementType": "geometry",
                    "stylers": [
                        {
                            "weight": 0.9
                        },
                        {
                            "visibility": "off"
                        }
                    ]
                },
                {
                    "featureType": "poi.park",
                    "elementType": "geometry.fill",
                    "stylers": [
                        {
                            "visibility": "on"
                        },
                        {
                            "color": "#83cead"
                        }
                    ]
                },
                {
                    "featureType": "road",
                    "elementType": "all",
                    "stylers": [
                        {
                            "visibility": "on"
                        },
                        {
                            "color": "#ffffff"
                        }
                    ]
                },
                {
                    "featureType": "road",
                    "elementType": "labels",
                    "stylers": [
                        {
                            "visibility": "on"
                        },
                        {
                            "lightness": "-21"
                        }
                    ]
                },
                {
                    "featureType": "road",
                    "elementType": "labels.text",
                    "stylers": [
                        {
                            "color": "#7a7676"
                        }
                    ]
                },
                {
                    "featureType": "road",
                    "elementType": "labels.text.stroke",
                    "stylers": [
                        {
                            "visibility": "off"
                        }
                    ]
                },
                {
                    "featureType": "road.highway",
                    "elementType": "all",
                    "stylers": [
                        {
                            "visibility": "on"
                        },
                        {
                            "color": "#fee379"
                        }
                    ]
                },
                {
                    "featureType": "road.highway",
                    "elementType": "geometry",
                    "stylers": [
                        {
                            "visibility": "on"
                        }
                    ]
                },
                {
                    "featureType": "road.highway",
                    "elementType": "labels",
                    "stylers": [
                        {
                            "visibility": "off"
                        }
                    ]
                },
                {
                    "featureType": "road.highway",
                    "elementType": "labels.icon",
                    "stylers": [
                        {
                            "visibility": "off"
                        }
                    ]
                },
                {
                    "featureType": "road.highway.controlled_access",
                    "elementType": "labels.icon",
                    "stylers": [
                        {
                            "visibility": "off"
                        }
                    ]
                },
                {
                    "featureType": "road.arterial",
                    "elementType": "all",
                    "stylers": [
                        {
                            "visibility": "simplified"
                        },
                        {
                            "color": "#ffffff"
                        }
                    ]
                },
                {
                    "featureType": "road.arterial",
                    "elementType": "labels",
                    "stylers": [
                        {
                            "visibility": "off"
                        }
                    ]
                },
                {
                    "featureType": "road.arterial",
                    "elementType": "labels.icon",
                    "stylers": [
                        {
                            "visibility": "off"
                        }
                    ]
                },
                {
                    "featureType": "water",
                    "elementType": "all",
                    "stylers": [
                        {
                            "visibility": "on"
                        },
                        {
                            "color": "#badbec"
                        }
                    ]
                }
            ];
    }
})