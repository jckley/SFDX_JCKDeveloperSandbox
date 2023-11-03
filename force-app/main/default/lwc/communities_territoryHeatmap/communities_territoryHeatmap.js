import { LightningElement,api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import leaflet from '@salesforce/resourceUrl/Leafleat';
import retrieveTerritory from '@salesforce/apex/TerritoryDetailController.retrieveTerritory';
import Resources from '@salesforce/resourceUrl/ExamplesJSON';

export default class TerritoryHeatmap extends LightningElement {
    @api recordid;    
    @api community;

    renderedCallback() {
        console.log('renderedCallback [] ->');

        Promise.all([
            loadScript(this, leaflet + '/leaflet.js'),
            //loadScript(this, leaflet + '/leaflet-heat.js'),
            loadStyle(this, leaflet + '/leaflet.css')
        ]).then(() => {
            console.log('initializeleaflet [recordId : ' + this.recordid + ' - community : ' + this.community + ']');

            retrieveTerritory( { 
                strTerritoryId : this.recordid,
                strCommunity : this.community 
            }).then(result => {
                console.log('initializeleaflet [' + this.recordid + ']');

                this.initializeleaflet(result);
            });
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',          
                    message: 'Ha ocurrido un error al cargar el mapa.',
                    variant: 'error'
                })
            );
        });

        console.log('renderedCallback [] <-');
    }
    
    initializeleaflet(territory) {        
        const divMap = this.template.querySelector(".map-root");
        var  objMap = null;
        var objLayer = null;
        var objCoordinates = null;
        var objLatLng = null;
        var strLink = null;
        var JSONFile = null;
        var markerArray = []; // array para calcular los límites de los puntos

        console.log('initializeleaflet [] ->');
        console.log('initializeleaflet [' + territory + ']');

        if(territory !== undefined && territory !== null && territory.geocode !== undefined && territory.geocode !== null && territory.geocode.length > 0) {
            objCoordinates = JSON.parse(territory.geocode);
        
            objMap = L.map(divMap).setView([39.7392, -104.991531], 1);  
            
            strLink = '<a href="http://prosumia.la">Prosumia</a>';

            objLayer = new L.tileLayer('http://{s}tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '<a href="http://prosumia.la">Prosumia</a>',
                maxZoom: 18,
                subdomains: ['a.', 'b.', 'c.', '']
            }).addTo(objMap);
    
            objLatLng = objCoordinates.centroide;
            

            // ****************************************************
            // función que obtiene el json
            // ****************************************************
            var getJSON = function(url, callback) {
                var xhr = new XMLHttpRequest();
                xhr.open('GET', url, true);
                xhr.responseType = 'json';
                xhr.onload = function() {
                    var status = xhr.status;
                    if (status == 200) {
                        callback(null, xhr.response);
                    } else {
                        callback(status);
                    }
                };
                xhr.send();
            };

            // var JSONFile = Resources + '/baires.json';

            // getJSON(JSONFile,  function(err, data) {
            //     if (err != null) {
            //         console.error(err);
            //     } else {
            //         objLatLng = L.GeoJSON.coordsToLatLng([-60.030515, -37.1471785]); // centro de BUENOS AIRES (más o menos)
            //         objMap.setView(objLatLng, 4); // el número es el zoom para BUENOS AIRES
            //         L.geoJson(data).addTo(objMap);
            //         console.log('provincia: ' + data.properties.provincia);
            //     }
            // });

            JSONFile = Resources + '/puntos.json';

            function onEachFeature(feature, layer) {
                // se agrega el marcador al punto
                layer.bindPopup(feature.properties.popupContent);
                // se agregan las coordenadas al array calculador
                // markerArray.push('[' + feature.geometry.coordinates + ']');

                console.log('punto: ' + feature.properties.name + ' coordenadas: ' + feature.geometry.coordinates);
                // console.log(markerArray);
            }

            getJSON(JSONFile,  function(err, data) {
                if (err != null) {
                    console.error(err);
                } else {
                    objLatLng = L.GeoJSON.coordsToLatLng([-58.4488121, -34.5556452]); // centro de Belgrano (más o menos)
                    objMap.setView(objLatLng, 12); // el número es el zoom para Belgrano
                    L.geoJson(data, {
                        onEachFeature: onEachFeature
                    } ).addTo(objMap);
                    // console.log('marker: ' + markerArray);
                    // objMap.fitBounds('[' + markerArray + ']');
                }
            });
            // var group = L.featureGroup(markerArray).addTo(objMap);
            // objMap.fitBounds(group.getBounds());
        }

        console.log('initializeleaflet [] <-');
    }

}