import { LightningElement,api,track,wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import leaflet from '@salesforce/resourceUrl/Leafleat';
import retrieveInfoFromCitizenId from '@salesforce/apex/CommunitiesController.retrieveInfoFromCitizenId';
import RESOURCES from '@salesforce/resourceUrl/Communities';

export default class Communities_contactLocationMap extends LightningElement {

    @track URL_GEOLOCATION = 'https://nominatim.openstreetmap.org/search?format=json&limit=3';
    @track arrAddress = [];
    @api recordId;
    @track record;
    @api rendered = false;
    @api community;
    @track intZoom = 18;

    @wire(retrieveInfoFromCitizenId, { contactId: '$recordId' })
    wiredContact({ error, data }) {
        if (data) {
            //console.log(JSON.stringify(data));
            this.record = data;
            this.error = undefined;
            this.initializeComponent();
            this.loadMapWithAddress();
        } else if (error) {
            console.error(error);
            console.error('error.name => ' + error.name );
            console.error('error.message => ' + error.message );
            console.error('error.stack => ' + error.stack );
            this.error = error;
            this.record = undefined;
        }
    }

    renderedCallback() {
        console.log('Communities_contactLocationMap In renderedCallback()...');
        loadScript(this, leaflet + '/leaflet.js');
        loadStyle(this, leaflet + '/leaflet.css');
    }

    initializeComponent() {
        
        if(this.record !== undefined && this.record !== null && this.record.citizen !== undefined && this.record.citizen !== null) {
            if(this.record.citizen.MailingStreet !== undefined && this.record.citizen.MailingStreet !== null) {
                if(this.record.citizen.MailingNumber__c !== undefined && this.record.citizen.MailingNumber__c !== null) {
                    this.arrAddress.push(this.record.citizen.MailingStreet + ' ' + this.record.citizen.MailingNumber__c);
                } else {
                    this.arrAddress.push(this.record.citizen.MailingStreet );
                }
            }

            if(this.record.citizen.Level4Name__c !== undefined && this.record.citizen.Level4Name__c !== null) {
                this.arrAddress.push(this.record.citizen.Level4Name__c );
            }

            if(this.record.citizen.Level3Name__c !== undefined && this.record.citizen.Level3Name__c !== null) {
                this.arrAddress.push(this.record.citizen.Level3Name__c );
            }

            if(this.record.citizen.Level2Name__c !== undefined && this.record.citizen.Level2Name__c !== null) {
                this.arrAddress.push(this.record.citizen.Level2Name__c );
            }

            if(this.record.citizen.Level1Name__c !== undefined && this.record.citizen.Level1Name__c !== null) {
                this.arrAddress.push(this.record.citizen.Level1Name__c );
            }

            this.arrAddress.push('Argentina');
       }
    }
    
    loadMapWithAddress() {	
		var strAddress = null;
		var strUrl = null;
		var dblLatitude = null;
		var dblLongitude = null;
		var objMap = null;

		if(this.arrAddress !== undefined && this.arrAddress !== null && this.arrAddress.length > 0) {
			strAddress = this.arrAddress.join(',');
			//console.log('loadMapWithAddress [strAddress : ' + strAddress + ']');

			strUrl = this.URL_GEOLOCATION + '&q=\'' + strAddress + '\'';
			//console.log('loadMapWithAddress [strUrl : ' + strUrl + ']');

			fetch(strUrl).then((objResponse) => objResponse.json()).then((objData) => {
				if(objData !== undefined && objData !== null && objData.length > 0) {
					//console.log('loadMapWithAddress [lat : ' + objData[0].lat + ']');
                    //console.log('loadMapWithAddress [lon : ' + objData[0].lon + ']');
                    
					dblLatitude  = objData[0].lat;
                    dblLongitude = objData[0].lon;
                    
                    const mapRoot = this.template.querySelector(".map-root");
                    objMap = L.map(mapRoot,  { zoomControl: false }).setView([dblLatitude, dblLongitude], this.intZoom)
			
					var CartoDB_Positron = L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
						attribution: '&copy; ' + this.community,
						subdomains: 'abcd',
						maxZoom: this.intZoom
					}).addTo(objMap);

                    var greenIcon = L.icon({
                        iconUrl: RESOURCES + '/SALESFORCE/img/iconMap.png',
                        // shadowUrl: RESOURCES + '/' + this.community_site + '/img/mail.svg',
                        iconSize:     [55, 60], // size of the icon
                        // shadowSize:   [50, 64], // size of the shadow
                        iconAnchor:   [50, 50], // point of the icon which will correspond to marker's location
                        // shadowAnchor: [4, 62],  // the same for the shadow
                        popupAnchor:  [-3, -56] // point from which the popup should open relative to the iconAnchor
                    });

                    L.marker([dblLatitude, dblLongitude], {icon: greenIcon}).addTo(objMap).bindPopup(strAddress);
                    
				} else {
					this.intZoom -= 2;
                    this.arrAddress = this.arrAddress.slice(1 , this.arrAddress.length); 
                    this.loadMapWithAddress();
				}
			}).catch(
				(error) => console.log('loadMapWithAddress [error : ' + error + ']')
			);
		}
    }
    
}