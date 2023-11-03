import { LightningElement, api, track, wire } from 'lwc';

import getTerritoryById_lt from '@salesforce/apex/TerritoryFullPageController_lt.getTerritoryById';
import createLog from '@salesforce/apex/TerritoryFullPageController_lt.createLog';

import Resources from '@salesforce/resourceUrl/Communities';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

// LEAFLET
import leaflet from '@salesforce/resourceUrl/Leafleat';
// AOS
import aos from '@salesforce/resourceUrl/AOS_JS_Library';


//los console.log en .catch() o cosas asi, deberian dejarse "comunes", para no desactivarlos con el flag, o ponerles el comando que los fuerza.
//los console.log para debuguear. Ver contenido de variables y cosas asi, se pueden usar con al funcion custom, para poder desactivarlos todos a la vez sin borrarlos
//la funcion forceLog, permite forzar a algun log en particular a mostrarse aunque esten todos apagados, se usaria asi: 
//customLog('estoy aca, debug puntual').forceLog();

const IS_LOG_ENABLED = false;

function customLog(...stringsToLog) {
    if (!IS_LOG_ENABLED || stringsToLog.length === 0) {
        return {forceLog:()=>console.log(...stringsToLog)};
    }
    console.log(...stringsToLog);
    return {forceLog:()=>null};
}

export default class testTableau extends LightningElement {

    // DEFINE ICONS
    iconRight = Resources + '/SALESFORCE/img/Territories/arrowrightps.svg';
    iconTerritories = Resources + '/SALESFORCE/img/Territories/territorio.svg';
    iconMarker = Resources + '/SALESFORCE/img/Territories/marker.svg';
    iconMapMarker = Resources + '/SALESFORCE/img/Territories/territorio.svg';
    

    @api recordId;  // = "a2L6A000000EIM4UAO"; // Buenos Aires PROD
    @api community;
    @api currentPage;
    @api makeLogs;

    //wire pendiente borrar
    @track territoryInfo = {};

    @track showMap = true;


    ORIGIN_PAGE = window.location.href.substring(0, window.location.href.indexOf('/s/'));
    URL_GEOLOCATION = 'https://nominatim.openstreetmap.org/search?format=json&limit=3';

    @track sticky_class = "sticky_container";
    @track all_page_class = "all-page";

    connectedCallback() {
        customLog("ConnectedCallback");
        customLog("recordId", this.recordId);

        window.addEventListener('scroll', (evt) => {
            this.template.querySelectorAll("[data-aos]").forEach((elem) => {
                if (this.element_is_visible(elem)) {
                    elem.classList.add("aos-init", "aos-animate");
                }
            });
        });

        this.sticky_class += " " + this.currentPage;
        this.all_page_class += " " + this.currentPage;

        if(this.makeLogs){
            createLog({recordId:this.recordId})
            .catch(error=>customLog('Ocurrio un error al intentar crear el log de la busqueda.').forceLog());
        }
    }

    element_is_visible(elem) {
        var base_top = 75;
        var docViewTop = window.scrollY;
        var docViewBottom = docViewTop + window.innerHeight;
        var elemTop = elem.offsetTop + base_top;
        let ans = ((elemTop + 250 < docViewBottom));
        return ans;
    }

    renderedCallback() {
        customLog("renderedCallback");
        this.loadAOS();
        this.loadLeafletJS();
        this.addAosClasses();
    }

    loadAOS() {
        // LOAD AOS
        if (this.aosLoaded) return
        loadStyle(this, aos + '/aos.css').then(() => {
            loadScript(this, aos + '/aos.js').then(() => {
                customLog("calling AOS_init");
                this.AOS_init();
                this.aosLoaded = true;
                customLog(".THEN loadScript AOS_init: END");
            });
        });
    }


    loadLeafletJS() {
        // LOAD LEAFLET JS
        if (this.leaftletjsLoaded) return
        customLog('renderingMap [] ->');
        Promise.all([
            loadScript(this, leaflet + '/leaflet.js'),
            loadStyle(this, leaflet + '/leaflet.css')
        ]).then(() => {
            customLog('initializeleaflet [recordId : ' + this.recordId + ' - community : ' + this.community + ']');
            this.leaftletjsLoaded = true;
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Ha ocurrido un error al cargar el mapa.',
                    variant: 'error'
                })
            );
        });
    }

    AOS_init() {
        customLog("initting AOS");
        // AOS.init();
        // AOS.refresh();

        // You can also pass an optional settings object
        // below listed default settings
        AOS.init({
            // Global settings:
            disable: false, // accepts following values: 'phone', 'tablet', 'mobile', boolean, expression or function
            startEvent: 'DOMContentLoaded', // name of the event dispatched on the document, that AOS should initialize on
            initClassName: 'aos-init', // class applied after initialization
            animatedClassName: 'aos-animate', // class applied on animation
            useClassNames: false, // if true, will add content of `data-aos` as classes on scroll
            disableMutationObserver: false, // disables automatic mutations' detections (advanced)
            debounceDelay: 50, // the delay on debounce used while resizing window (advanced)
            throttleDelay: 99, // the delay on throttle used while scrolling the page (advanced)

            // Settings that can be overridden on per-element basis, by `data-aos-*` attributes:
            offset: 120, // offset (in px) from the original trigger point
            delay: 0, // values from 0 to 3000, with step 50ms
            duration: 400, // values from 0 to 3000, with step 50ms
            easing: 'ease', // default easing for AOS animations
            once: false, // whether animation should happen only once - while scrolling down
            mirror: false, // whether elements should animate out while scrolling past them
            anchorPlacement: 'top-bottom', // defines which position of the element regarding to window should trigger the animation
        });
        customLog('End AOS INIT');
    }

    addAosClasses() {
        //esto no pareciera necesitar que la libreria este cargada y/o incializada.
        customLog("Init addAosClasses");
        if (this.aosClassesAdded) return;
        customLog("AddAosClasses --> LOGIC");
        let elementsForAnimate = this.template.querySelectorAll("[data-aos]");
        customLog("AddAosClasses ElementsArray: ", JSON.stringify(elementsForAnimate));
        elementsForAnimate.forEach((elem) => {
            //if (this.element_is_visible(elem))
            elem.classList.add("aos-init", "aos-animate");
        });
        if (elementsForAnimate.length !== 0) this.aosClassesAdded = true;
    }

    initializeleaflet() {
        if (this.leafletInitialized) return
        var strAddress = null;

        let territoryAdminLevel = this.territoryLt.Nivel_Administrativo__c;

        if (territoryAdminLevel === 4) {
            strAddress =
                `&q='${this.territoryLt.Name}, ` +
                `${this.territoryLt.ParentId__r.Name}, ` +
                `${this.territoryLt.ParentId__r.ParentId__r.Name}, ` +
                `${this.territoryLt.ParentId__r.ParentId__r.ParentId__r.Name}, ` +
                `${this.territoryLt.ParentId__r.ParentId__r.ParentId__r.ParentId__rName}'`

            this.drawingMap(strAddress);
            return
        }
        if (territoryAdminLevel === 3) {
            strAddress =
                `&city=${this.territoryLt.Name}` +
                `&county=${this.territoryLt.ParentId__r.Name}` +
                `&state=${this.territoryLt.ParentId__r.ParentId__r.Name}` +
                `&country=${this.territoryLt.ParentId__r.ParentId__r.ParentId__r.Name}`

            this.drawingMap(strAddress);
            return
        }
        if (territoryAdminLevel === 2) {
            strAddress =
                `&county=${this.territoryLt.Name}` +
                `&state=${this.territoryLt.ParentId__r.Name}` +
                `&country=${this.territoryLt.ParentId__r.ParentId__r.Name}`

            this.drawingMap(strAddress);
            return
        }
        if (territoryAdminLevel === 1) {
            strAddress =
                `&state=${this.territoryLt.Name}` +
                `&country=${this.territoryLt.ParentId__r.Name}`

            this.drawingMap(strAddress);
            return
        }
        if (territoryAdminLevel === 0) {
            strAddress =
                `&country=${this.territoryLt.Name}`

            this.drawingMap(strAddress);
            return
        }

        strAddress = `&q='${this.territoryLt.Name}'`
        this.drawingMap(strAddress);
    }

    drawingMap(strAddress) {
        var strUrl = this.URL_GEOLOCATION + strAddress;

        var dblLatitude = null;
        var dblLongitude = null;
        var objMap = null;
        var intZoom = 8;
        var maxZoom = 18;

        fetch(strUrl)
            .then((objResponse) => objResponse.json())
            .then((objData) => {
                if (objData !== undefined && objData !== null && objData.length > 0) {
                    dblLatitude = (parseFloat(objData[0].boundingbox[0]) + parseFloat(objData[0].boundingbox[1])) / 2;
                    dblLongitude = (parseFloat(objData[0].boundingbox[2]) + parseFloat(objData[0].boundingbox[3])) / 2;

                    const mapRoot = this.template.querySelector(".map_container");
                    objMap = L.map(mapRoot, { tap: false }).setView([dblLatitude, dblLongitude], intZoom)


                    var myPoints = [[objData[0].boundingbox[0], objData[0].boundingbox[2]], [objData[0].boundingbox[1], objData[0].boundingbox[3]]];
                    objMap.fitBounds(myPoints);

                    var CartoDB_Positron = L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
                        attribution: '&copy; ' + this.community,
                        subdomains: 'abcd',
                        maxZoom: maxZoom
                    }).addTo(objMap);

                    var greenIcon = L.icon({
                        iconUrl: this.iconMarker,
                        // shadowUrl: RESOURCES + '/' + this.community_site + '/img/mail.svg',
                        iconSize: [55, 60], // size of the icon
                        // shadowSize:   [50, 64], // size of the shadow
                        iconAnchor: [50, 50], // point of the icon which will correspond to marker's location
                        // shadowAnchor: [4, 62],  // the same for the shadow
                        popupAnchor: [-3, -56] // point from which the popup should open relative to the iconAnchor
                    });

                    L.marker([dblLatitude, dblLongitude], { icon: greenIcon }).addTo(objMap).bindPopup(this.territoryLt.Name);
                    this.showMap = true;
                    this.leafletInitialized = true;
                    customLog('Se dibuja mapa');
                } else {
                    this.showMap = false;

                    let territoryAdminLevel = this.territoryLt.Nivel_Administrativo__c;

                    if (territoryAdminLevel === 4) {
                        strAddress =
                            '&q=\'' +
                            this.territoryLt.Name + ',' +
                            this.territoryLt?.ParentId__r?.ParentId__r?.Name + ',' +
                            this.territoryLt?.ParentId__r?.ParentId__r?.ParentId__r?.Name + ',' +
                            this.territoryLt?.ParentId__r?.ParentId__r?.ParentId__r?.ParentId__r?.Name + '\''
                    }
                    if (territoryAdminLevel === 3) {
                        strAddress = '&q=\'' +
                            this.territoryLt.Name + ',' +
                            this.territoryLt?.ParentId__r?.ParentId__r?.ParentId__r?.Name + '\''
                    }
                    if (territoryAdminLevel === 2) {
                        strAddress = '&q=\'' +
                            this.territoryLt.Name + ',' +
                            this.territoryLt?.ParentId__r?.ParentId__r?.Name + '\'';
                    }
                    if (territoryAdminLevel === 1) {
                        strAddress = '&q=\'' +
                            this.territoryLt.Name + ',' +
                            this.territoryLt?.ParentId__r?.Name + '\'';
                    }

                    this.drawingMap(strAddress);
                }
            }).catch(
                (error) => {
                    console.log('ERROR EN initializeleaflet : ' + JSON.stringify(error))
                }
            );
    }

    dataFromAnalytics;
    territoryLt;
    _analitycsManager;
    loadingForNewData = false;

    get analitycsManager() {
        customLog('get analitycsManager')
        if (!this._analitycsManager) {
            this._analitycsManager = this.template.querySelector('c-analytics-manager-territory');
        }

        return this._analitycsManager;
    }

    leafletInitialized;

    handleQueryData(e) {
        this.dataFromAnalytics = { ...e.detail };
        customLog('handleQueryData: ', JSON.stringify(this.dataFromAnalytics));
        customLog('handleQueryData, datos completos');
        this.loadingForNewData = false;
        this.initializeleaflet();
    }

    get isAnalitycsReady() {
        return Boolean(this.dataFromAnalytics);
    }

    get loadingScreenOn() {
        return (!this.isAnalitycsReady || this.loadingForNewData)
    }

    handleQueryError(e) {
        console.log('fullterritory_analytics error: ', JSON.stringify(e.detail));
    }

    @wire(getTerritoryById_lt, { territoryId: '$recordId' })
    wiredTerritoryLt({ error, data }) {
        if (error) {
            console.log('Ocurrio un error en WIRE getTerritoryById_lt', JSON.stringify(error))
        }
        if (data) {
            customLog('getTerritoryById_lt, DATA', JSON.stringify(data));
            this.territoryLt = data[0];
        }
    }

    get analitycsManagerParams() {
        if (!this.territoryLt) return undefined
        let nivelAdmin = this.territoryLt.Nivel_Administrativo__c

        let child_level_name = `Level${nivelAdmin + 1}Name__c`;
        let child_level_id = `Level${nivelAdmin + 1}ID__c`

        let dataset_name = "TerritoryFullPage_DS";

        let territory_id = this.recordId.length === 18 ? this.recordId.slice(0, -3) : this.recordId;

        let tempObject = {
            child_level_name,
            child_level_id,
            dataset_name,
            territory_id
        }

        return tempObject;
    }

    get areManagerParamsReady() {
        return Boolean(this.analitycsManagerParams);
    }

    get analitycsGenderData() {
        let womenSumary = 0;
        let menSumary = 0;
        let otherSumary = 0;
        let totalSumary = 0;
        let womenPercent = 0;
        let menPercent = 0;
        let othermenPercent = 0;

        this.dataFromAnalytics.Gender.results.forEach(thisData => {
            if (thisData.Genero === 'f') {
                womenSumary = thisData.count;
            } else if (thisData.Genero === 'm') {
                menSumary = thisData.count;
            } else {
                otherSumary += thisData.count;
            }
            totalSumary += thisData.count;
        })

        womenPercent = womenSumary / totalSumary * 100;
        menPercent = menSumary / totalSumary * 100;
        othermenPercent = otherSumary / totalSumary * 100;

        womenPercent = parseFloat(womenPercent).toFixed(2);
        menPercent = parseFloat(menPercent).toFixed(2);
        othermenPercent = parseFloat(othermenPercent).toFixed(2);

        let menSumaryFormated = menSumary.toLocaleString('es-AR');
        let womenSumaryFormated = womenSumary.toLocaleString('es-AR');
        let totalSumaryFormated = totalSumary.toLocaleString('es-AR');

        let tempObject = {
            womenSumary,
            menSumary,
            otherSumary,
            totalSumary,
            womenPercent,
            menPercent,
            othermenPercent,
            womenSumaryFormated,
            menSumaryFormated,
            totalSumaryFormated
        }

        return tempObject;
    }

    handleFilterClickOnComponent(event){
        this.toggleFilter(event.detail.filterObject, event.detail.label, event.detail.bindedFunction);
    }

    get parentsArrayNavigation() {
        // set array_adminLevel
        let territoryData = this.territoryLt;

        let admLevelLink = '';

        if (this.currentPage === 'Community') {
            admLevelLink = this.ORIGIN_PAGE + '/s/territorio-administrativo/';
        } else {
            admLevelLink = this.ORIGIN_PAGE + '/lightning/r/Territorio_Administrativo__c/';
        }

        let tempArrayAdminLevel = [];

        if (territoryData.ParentId__c) {
            tempArrayAdminLevel.unshift(
                {
                    "id": territoryData.ParentId__c,
                    "name": territoryData.ParentId__r.Name,
                    "link": admLevelLink + territoryData.ParentId__c + '/view',
                    "isLast": false
                }
            )
        }
        if (territoryData.ParentId__r?.ParentId__c) {
            tempArrayAdminLevel.unshift(
                {
                    "id": territoryData.ParentId__r.ParentId__c,
                    "name": territoryData.ParentId__r.ParentId__r.Name,
                    "link": admLevelLink + territoryData.ParentId__r.ParentId__c + '/view',
                    "isLast": false
                }
            )
        }
        if (territoryData.ParentId__r?.ParentId__r?.ParentId__c) {
            tempArrayAdminLevel.unshift(
                {
                    "id": territoryData.ParentId__r.ParentId__r.ParentId__c,
                    "name": territoryData.ParentId__r.ParentId__r.ParentId__r.Name,
                    "link": admLevelLink + territoryData.ParentId__r.ParentId__r.ParentId__c + '/view',
                    "isLast": false
                }
            )
        }
        if (territoryData.ParentId__r?.ParentId__r?.ParentId__r?.ParentId__c) {
            tempArrayAdminLevel.unshift(
                {
                    "id": territoryData.ParentId__r.ParentId__r.ParentId__r.ParentId__c,
                    "name": territoryData.ParentId__r.ParentId__r.ParentId__r.ParentId__r.Name,
                    "link": admLevelLink + territoryData.ParentId__r.ParentId__r.ParentId__r.ParentId__c + '/view',
                    "isLast": false
                }
            )
        }
        if (tempArrayAdminLevel.length > 0) {
            tempArrayAdminLevel[(tempArrayAdminLevel.length) - 1].isLast = true;
        }

        return tempArrayAdminLevel;
    }

    get parentLvlNavigation() {
        let thisTerritoryInfo = `Territorio, Nivel administrativo ${this.territoryLt.Nivel_Administrativo__c}`

        let parentTerritoryInfo;

        if (this.territoryLt.ParentId__c) {
            let parentLink;
            if (this.currentPage === 'Community') {
                parentLink = this.ORIGIN_PAGE + '/s/territorio-administrativo/';
            } else {
                parentLink = this.ORIGIN_PAGE + '/lightning/r/Territorio_Administrativo__c/';
            }

            parentTerritoryInfo = {
                info: `Territorio padre: ${this.territoryLt.ParentId__r.Name} `,
                link: parentLink + this.territoryLt.ParentId__c + '/view'
            }
        }

        let tempParentLvlNavigation = {
            thisTerritoryInfo,
            parentTerritoryInfo
        }

        return tempParentLvlNavigation;
    }

    get showGeographicDistribution() {
        return (this.geographicDistribution.length > 0);
    }

    get geographicDistribution() {
        customLog('geographicDistribution').forceLog();
        let tempArray = [];

        let childTerritoriesFromAnalitycs = this.dataFromAnalytics.ChildTerritories.results;

        for (let thisTerritory of childTerritoriesFromAnalitycs) {

            let link;
            if (this.currentPage === 'Community') {
                link = this.ORIGIN_PAGE + '/s/territorio-administrativo/';
            } else {
                link = this.ORIGIN_PAGE + '/lightning/r/Territorio_Administrativo__c/';
            }

            tempArray.push(
                {
                    "id": thisTerritory.Id,
                    "link": link + thisTerritory.Id + '/view',
                    "name": thisTerritory.Name,
                    "value": thisTerritory.count
                }
            );
        }


        let sortedArray = tempArray.sort((a, b) => { return b.value - a.value });

        //un poco de mutacion por aqui, un poco de mutacion por alla
        sortedArray.forEach(thisElement => {
            thisElement.value = thisElement.value.toLocaleString('es-AR')
        })

        return tempArray;
    }

    toggleFilter(filter, filterLabel, bindedFunction) {
        this.loadingForNewData = true;
        this.template.querySelector('.filterComponent').toggleFilter({filterLabel:filterLabel,filterString:JSON.stringify(filter), bindedFunction});
        this.analitycsManager.toggleTemporaryFilter(filter);
    }

    handleRemoveOneFilter (event) {
        this.loadingForNewData = true;
        const filter = JSON.parse(event.detail.filterString);
        this.analitycsManager.toggleTemporaryFilter(filter);
    }

    handleRemoveAllFilters () {
        this.loadingForNewData = true;
        console.log(1)
        this.template.querySelector('c-section_gender-doughnut').removeAllLocalFilters();
        console.log(2)
        this.template.querySelector('c-section_ingreso').removeAllLocalFilters();
        console.log(3)
        this.template.querySelector('c-section_ocupacion').removeAllLocalFilters();
        console.log(4)
        this.template.querySelector('c-section_educacion').removeAllLocalFilters();
        console.log(5)
        this.template.querySelector('c-section_actividades-economicas').removeAllLocalFilters();
        console.log(6)
        this.analitycsManager.clearAllTemporaryFilters();
    }

}