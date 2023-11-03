({
    initializeComponent : function(objComponent, objEvent, objHelper) {
        var objCitizenWrapper = null;
        var community = "";
        var intZoom = 18;
        var arrAddress = [];

        objCitizenWrapper = objComponent.get('v.citizenWrapper');
        community = objComponent.get('v.community');

        if(objCitizenWrapper !== undefined && objCitizenWrapper !== null && objCitizenWrapper.citizen !== undefined && objCitizenWrapper.citizen !== null) {
            if(objCitizenWrapper.citizen.MailingStreet !== undefined && objCitizenWrapper.citizen.MailingStreet !== null) {
                if(objCitizenWrapper.citizen.MailingNumber__c !== undefined && objCitizenWrapper.citizen.MailingNumber__c !== null) {
                    arrAddress.push(objCitizenWrapper.citizen.MailingStreet + ' ' + objCitizenWrapper.citizen.MailingNumber__c);
                } else {
                    arrAddress.push(objCitizenWrapper.citizen.MailingStreet );
                }
            }

            if(objCitizenWrapper.citizen.Level4Name__c !== undefined && objCitizenWrapper.citizen.Level4Name__c !== null) {
                arrAddress.push(objCitizenWrapper.citizen.Level4Name__c );
            }

            if(objCitizenWrapper.citizen.Level3Name__c !== undefined && objCitizenWrapper.citizen.Level3Name__c !== null) {
                arrAddress.push(objCitizenWrapper.citizen.Level3Name__c );
            }

            if(objCitizenWrapper.citizen.Level2Name__c !== undefined && objCitizenWrapper.citizen.Level2Name__c !== null) {
                arrAddress.push(objCitizenWrapper.citizen.Level2Name__c );
            }

            if(objCitizenWrapper.citizen.Level1Name__c !== undefined && objCitizenWrapper.citizen.Level1Name__c !== null) {
                arrAddress.push(objCitizenWrapper.citizen.Level1Name__c );
            }

            arrAddress.push('Argentina');

            objHelper.loadMapWithAddress(objCitizenWrapper, arrAddress, intZoom, objHelper, community);
        }
    },
    jsLoaded: function (component, event, helper) {
        setTimeout(function () {
            var latitude = component.get('v.latitude');
            var longitude = component.get('v.longitude');

            fetch("https://nominatim.openstreetmap.org/search?format=json&limit=3&q='Avenida Santa Fe 3446 Buenos Aires'")
                .then((resp) => resp.json())
                .then((data) => {
                    console.log(data[0].lat);
                    console.log(data[0].lon);

                    latitude = data[0].lat;
                    longitude = data[0].lon;

                    var map = L.map('map', { zoomControl: false }).setView([latitude, longitude], 14);
                    L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                        { attribution: 'Cuidarnos' }).addTo(map);

                    // Add marker
                    L.marker([latitude, longitude]).addTo(map)
                        .bindPopup('Home of Dreamforce');
                })
                .catch((error) => console.log(error));

        })
    }
})