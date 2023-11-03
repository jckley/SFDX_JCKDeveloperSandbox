import { LightningElement, api, track, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import leaflet from '@salesforce/resourceUrl/Leafleat';
import Resources from '@salesforce/resourceUrl/Communities';

const LOCATION_DATA = '[{"place_id":283393649,"licence":"Data © OpenStreetMap contributors, ODbL 1.0. https://osm.org/copyright","osm_type":"relation","osm_id":4438708,"boundingbox":["-37.1848278","-37.1232509","-58.5341725","-58.4220737"],"lat":"-37.1527789","lon":"-58.4884611","display_name":"Ayacucho, Partido de Ayacucho, Buenos Aires, 7150, Argentina","class":"boundary","type":"administrative","importance":0.8443170044259858,"icon":"https://nominatim.openstreetmap.org/ui/mapicons/poi_boundary_administrative.p.20.png"}]';
const TERRITORY_NAME = 'ayacucho';

export default class Tableau_map extends LightningElement {

    iconMarker = Resources + '/SALESFORCE/img/Territories/marker.svg';

    renderedCallback() {
        if (this._leafletReady) return

        Promise.all(
            [
                loadScript(this, leaflet + '/leaflet.js'),
                loadStyle(this, leaflet + '/leaflet.css')
            ]
        ).then(
            () => {
                this._leafletReady = true;
                this.drawingMap(LOCATION_DATA);
            }
        ).catch(
            error => console.log('Tableau_map: error loading leaflet', JSON.stringify(error))
        );
    }

    drawingMap(locationData) {
        let dataObj = JSON.parse(locationData);

        let intZoom = 8;
        let maxZoom = 18;

        let dblLatitude = (parseFloat(dataObj[0].boundingbox[0]) + parseFloat(dataObj[0].boundingbox[1])) / 2;
        let dblLongitude = (parseFloat(dataObj[0].boundingbox[2]) + parseFloat(dataObj[0].boundingbox[3])) / 2;

        const mapRoot = this.template.querySelector(".map_container");
        let objMap = L.map(mapRoot, { tap: false }).setView([dblLatitude, dblLongitude], intZoom)

        let myPoints = [[dataObj[0].boundingbox[0], dataObj[0].boundingbox[2]], [dataObj[0].boundingbox[1], dataObj[0].boundingbox[3]]];

        objMap.fitBounds(myPoints);

        let CartoDB_Positron = L.tileLayer(
            'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
            {
                attribution: '&copy; Prosumia',
                subdomains: 'abcd',
                maxZoom: maxZoom
            }
        )

        CartoDB_Positron.addTo(objMap);

        let greenIcon = L.icon({
            iconUrl: this.iconMarker,
            iconSize: [55, 60], // size of the icon
            iconAnchor: [50, 50], // point of the icon which will correspond to marker's location
            popupAnchor: [-3, -56] // point from which the popup should open relative to the iconAnchor
        });

        L.marker(
            [dblLatitude, dblLongitude],
            { icon: greenIcon }).addTo(objMap).bindPopup(TERRITORY_NAME);
    }
}