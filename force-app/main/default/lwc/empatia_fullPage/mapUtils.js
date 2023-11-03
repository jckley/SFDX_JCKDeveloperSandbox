function renderMap (scenario) {
    let dblLatitude = null;
    let dblLongitude = null;

    let arrAddress = [];
    let arrAddress2 = [];

    if (this.record.Empatia_Activista__r.Citizen__r !== undefined && this.record.Empatia_Activista__r.Citizen__r !== null) {
        if (this.record.Empatia_Activista__r.Citizen__r?.MailingStreet !== undefined && this.record.Empatia_Activista__r.Citizen__r?.MailingStreet !== null && scenario == 0) {
            if (this.record.Empatia_Activista__r.Citizen__r?.MailingNumber__c !== undefined && this.record.Empatia_Activista__r.Citizen__r?.MailingNumber__c !== null) {
                arrAddress.push(this.record.Empatia_Activista__r.Citizen__r?.MailingStreet + ' ' + this.record.Empatia_Activista__r.Citizen__r?.MailingNumber__c);
                arrAddress2.push("street=" + encodeURIComponent(this.record.Empatia_Activista__r.Citizen__r?.MailingStreet + ' ' + this.record.Empatia_Activista__r.Citizen__r?.MailingNumber__c));
            } else {
                arrAddress.push(this.record.Empatia_Activista__r.Citizen__r?.MailingStreet);
                arrAddress2.push("street=" + encodeURIComponent(this.record.Empatia_Activista__r.Citizen__r?.MailingStreet));
            }
        }

        if (this.record.Empatia_Activista__r.Citizen__r?.Level4Name__c !== undefined && this.record.Empatia_Activista__r.Citizen__r?.Level4Name__c !== null) {
            arrAddress.push(this.record.Empatia_Activista__r.Citizen__r?.Level4Name__c);
        }

        if (this.record.Empatia_Activista__r.Citizen__r?.Level3Name__c !== undefined && this.record.Empatia_Activista__r.Citizen__r?.Level3Name__c !== null) {
            arrAddress.push(this.record.Empatia_Activista__r.Citizen__r?.Level3Name__c);
            arrAddress2.push("city=" + encodeURIComponent(this.record.Empatia_Activista__r.Citizen__r?.Level3Name__c));
        }

        if (this.record.Empatia_Activista__r.Citizen__r?.Level2Name__c !== undefined && this.record.Empatia_Activista__r.Citizen__r?.Level2Name__c !== null) {
            arrAddress.push(this.record.Empatia_Activista__r.Citizen__r?.Level2Name__c);
            arrAddress2.push("county=" + encodeURIComponent(this.record.Empatia_Activista__r.Citizen__r?.Level2Name__c));
        }

        if (this.record.Empatia_Activista__r.Citizen__r?.Level1Name__c !== undefined && this.record.Empatia_Activista__r.Citizen__r?.Level1Name__c !== null) {
            arrAddress.push(this.record.Empatia_Activista__r.Citizen__r?.Level1Name__c);
            arrAddress2.push("state=" + encodeURIComponent(this.record.Empatia_Activista__r.Citizen__r?.Level1Name__c));
        }

        arrAddress.push('Argentina');
        arrAddress2.push("country=Argentina");
    }

    let strAddress = null;
    let strUrl = null;

    let strAddress2 = null;
    let strUrl2 = null;

    let URL_GEOLOCATION = 'https://nominatim.openstreetmap.org/search?format=json&limit=3';

    if (arrAddress !== undefined && arrAddress !== null && arrAddress.length > 0) {
        strAddress = arrAddress.join(',');
        strAddress2 = arrAddress2.join('&');

        strUrl = URL_GEOLOCATION + '&q=\'' + strAddress + '\'';
        strUrl2 = URL_GEOLOCATION + '&' + strAddress2;

        fetch(strUrl2)
            .then((objResponse) => objResponse.json())
            .then((objData) => {
                if (objData !== undefined && objData !== null && objData.length > 0) {

                    this.hasMapView = true;

                    dblLatitude = objData[0].lat;
                    dblLongitude = objData[0].lon;

                    if (scenario == 0) {
                        this.streetviewURL = `https://www.google.com/maps/embed/v1/streetview?key=AIzaSyDSj74xvmqOUCpTnzhRWUegA4XCGcOc5ro&location=${dblLatitude},${dblLongitude}`;
                        this.hasStreetView = true;
                    } else {
                        this.hasStreetView = false;
                    }

                    let position = [dblLatitude, dblLongitude];

                    let mymap = L.map(this.template.querySelector(".map_container"), {
                        scrollWheelZoom: false,
                        dragging: false,
                        tap: false
                    }).setView(position, 18);

                    let CartoDB_Positron = L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
                        subdomains: 'abcd',
                        maxZoom: this.intZoom
                    }).addTo(mymap);

                    let locationLayer = new L.FeatureGroup();

                    let markerTemp = L.marker([dblLatitude, dblLongitude]).addTo(mymap);
                } else {
                    if (scenario == 0)
                        this.renderMap(1);
                    else
                        this.hasMapView = false;
                }
            });
    }
    this.template.dispatchEvent(new Event("ready"));
    window.dispatchEvent(new Event('ready'));
    window.dispatchEvent(new Event('DOMContentLoaded'));
}

export {renderMap};