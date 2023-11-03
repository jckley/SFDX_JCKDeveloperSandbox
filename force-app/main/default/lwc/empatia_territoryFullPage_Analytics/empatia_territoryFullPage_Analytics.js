import { LightningElement, api, track, wire } from 'lwc';

import getTerritoryById_lt from '@salesforce/apex/TerritoryFullPageController_lt.getTerritoryById';
import createLog from '@salesforce/apex/TerritoryFullPageController_lt.createLog';

import Resources from '@salesforce/resourceUrl/Communities';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

import lblsmvm from '@salesforce/label/c.SMVM';

// LEAFLET
import leaflet from '@salesforce/resourceUrl/Leafleat';
// AOS
import aos from '@salesforce/resourceUrl/AOS_JS_Library';
// ChartJS
import chartjs from '@salesforce/resourceUrl/ChartJS';

//import chartjs from '@salesforce/resourceUrl/ChartJS38';


//los console.log en .catch() o cosas asi, deberian dejarse "comunes", para no desactivarlos con el flag.
//los console.log para debuguear. Ver contenido de variables y cosas asi, se pueden usar con al funcion custom, para poder desactivarlos todos a la vez sin borrarlos
const IS_LOG_ENABLED = false;

function customLog(...stringsToLog) {
    if (!IS_LOG_ENABLED || stringsToLog.length === 0) {
        return {forceLog:()=>console.log(...stringsToLog)};
    }
    console.log(...stringsToLog);
    return {forceLog:()=>null};
}


const PICK_LIST_TO_CHART_LABELS = {
    //el orden de las columnas va a venir dado por el orden del array de equivalencias.
    array: [
        { chartLabel: [['Sub'], ['16']], pickListValue: 'SUB 16' },
        { chartLabel: ['Centenials'], pickListValue: 'CENTENNIALS' },
        { chartLabel: ['Milenials'], pickListValue: 'MILENNIALS' },
        { chartLabel: [['Generación'], ['X']], pickListValue: 'GENERACION X' },
        { chartLabel: [['Baby'], ['Boomers']], pickListValue: 'BABY BOOMERS' },
        { chartLabel: [['Generación'], ['Silenciosa']], pickListValue: 'GENERACION SILENCIOSA' },
    ],

    getLabels() {
        return this.array.map(thisEquivalencia => thisEquivalencia.chartLabel)
    },

    getPickListValues() {
        return this.array.map(thisEquivalencia => thisEquivalencia.pickListValue)
    }
}

//esto esta maso, hay que verificar que siempre esten sincronizados con los valores que usa y que espera la query.
//pero bueno, a su vez, el requerimiento es que las actividades se tienen que mostrar aunque la query de 0 (en cuyo caso no la devuelve)
const ACTIVIDADES_ECONOMICAS_DEFAULT = {
    'Arte y recreación': 0,
    'Comercio': 0,
    'Comunicación e información': 0,
    'Construcción': 0,
    'Gestión de desechos': 0,
    'Educación': 0,
    'Extractivismo': 0,
    'Finanzas y aseguradoras': 0,
    'Gas y electricidad': 0,
    'Hotelería y gastronomía': 0,
    'Industrias manufactureras': 0,
    'Inmobiliarias': 0,
    'Justicia': 0,
    'Reparaciones y oficios': 0,
    'Empleo público': 0,
    'Reparaciones y suministro de servicios básicos': 0,
    'Rural': 0,
    'Salud': 0,
    'Fuerzas de seguridad': 0,
    'Servicios profesionales': 0,
    'Tecnología': 0,
    'Transporte': 0,
}

const WOMEN_COLOR = '#885493';
const MEN_COLOR = '#0082be';

export default class empatia_territoryFullPage_Analytics extends LightningElement {

    label = {
        lblsmvm
    };

    // DEFINE ICONS
    iconRight = Resources + '/SALESFORCE/img/Territories/arrowrightps.svg';
    iconTerritories = Resources + '/SALESFORCE/img/Territories/territorio.svg';
    iconMarker = Resources + '/SALESFORCE/img/Territories/marker.svg';
    iconMapMarker = Resources + '/SALESFORCE/img/Territories/territorio.svg';
    iconIngresoBajo = Resources + '/SALESFORCE/img/Territories/indicador_bajo.svg';
    iconIngresoMedio = Resources + '/SALESFORCE/img/Territories/indicador_medio.svg';
    iconIngresoAlto = Resources + '/SALESFORCE/img/Territories/indicador_alto.svg';
    iconOcuAsalariado = Resources + '/SALESFORCE/img/Territories/icon_asalariado.svg';
    iconOcuCuentapropista = Resources + '/SALESFORCE/img/Territories/icon_cuentaprop.svg';
    iconOcuJubilado = Resources + '/SALESFORCE/img/Territories/icon_jubilado.svg';
    iconOcuSinIngreso = Resources + '/SALESFORCE/img/Territories/icon_siningresos.svg';
    iconEduPrimaria = Resources + '/SALESFORCE/img/Territories/ne_primario.svg';
    iconEduSecundaria = Resources + '/SALESFORCE/img/Territories/ne_secundario.svg';
    iconEduTerciaria = Resources + '/SALESFORCE/img/Territories/ne_universitario.svg';
    iconEduUniversitaria = Resources + '/SALESFORCE/img/Territories/ne_universitario_completo.svg';
    iconEmpleado = Resources + '/SALESFORCE/img/Territories/ae_empleado.svg';

    @api recordId //= "a2L6A000000EIM4UAO"; // Buenos Aires PROD
    @api community;
    @api currentPage;
    @api makeLogs;

    //wire pendiente borrar
    @track territoryInfo = {};

    @track showMap = true;



    // @track charttext = '';
    @track chartjsTooltip = ''

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

    callCharts() {
        customLog('inicio callCharts');
        try {
            //el render de la pagina no implica que se hayan generado los canvas.
            let canvasRendered = this.canvasPopulation && this.canvasAge
            if (this.isAnalitycsReady && this.chartjsLoaded && canvasRendered) {
                customLog('callCharts genero los graficos');
                this.ageChart();
                this.populationChart();
            }
        } catch (error) {
            console.log('ERROR ON CALL CHARTS: ', error);
        }
    }

    element_is_visible(elem) {
        var base_top = 75;
        var docViewTop = window.scrollY;
        var docViewBottom = docViewTop + window.innerHeight;
        var elemTop = elem.offsetTop + base_top;
        var elemBottom = elemTop + elem.offsetHeight;
        // let ans = ((elemBottom <= docViewBottom) && (elemTop >= docViewTop));
        let ans = ((elemTop + 250 < docViewBottom));
        return ans;
    }

    renderedCallback() {
        customLog("renderedCallback");
        customLog('canvas.ageChart', this.template.querySelector('canvas.ageChart'))
        customLog('canvas.populationChart', this.template.querySelector('canvas.populationChart'))
        this.loadAOS();
        this.loadLeafletJS();
        this.loadChartJS();
        this.callCharts();
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

    loadChartJS() {
        if (this.chartjsLoaded) return;
        // LOAD CHART JS
        loadScript(this, chartjs + '/Chart.bundle.min.js')
            .then(() => {
                this.chartjsLoaded = true;
            })
        //.catch(error => console.log('Error on loadChartJS: ', JSON.stringify(error)));
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

    // chart de distribución etaria

    ageChart() {
        customLog('Init ageChart');
        if (this.chartAge) return;

        let labels = PICK_LIST_TO_CHART_LABELS.getLabels();

        let dataObject = this.analitycsAgesData;

        let maleData = dataObject.m;
        let femaleData = dataObject.f;

        customLog('Get labels?');
        const dataResponse = {
            // These labels appear in the legend and in the tooltips when hovering different arcs
            labels,
            datasets: [
                {
                    label: 'Hombres',
                    data: maleData,
                    backgroundColor: MEN_COLOR,
                    stack: 'Stack 0',
                }, {
                    label: 'Mujeres',
                    data: femaleData,
                    backgroundColor: WOMEN_COLOR,
                    stack: 'Stack 0',
                }
            ]

        };


        const config = {
            type: 'bar',
            data: dataResponse,
            options: {
                y: {
                    beginAtZero: true
                }
                , plugins: {
                    title: {
                        display: false
                    },
                    legend: false,
                    tooltip: false,

                }
                , layout: {
                    padding: 10
                },
                responsive: true,
                scales: {
                    x: {
                        stacked: true,
                    },
                    y: {
                        stacked: true,
                    },
                    yAxes: [{
                        ticks: {
                            callback: function (label, index, labels) {
                                if (label > 1000000) {
                                    return label / 1000000 + ' millones';
                                } else if (label > 1000) {
                                    var miles = label / 1000 < 1000 ? ' miles' : ' millón';
                                    var cantidad = label / 1000 < 1000 ? label / 1000 : label / 1000000;
                                    return cantidad + miles;
                                } else {
                                    return label;
                                }
                            }
                        }
                    }],
                    xAxes: [{
                        ticks: {
                            autoSkip: false
                        }
                    }]
                }
            },
        }
        let ctx = this.template.querySelector('canvas.ageChart').getContext('2d');

        this.chartAge = new Chart(ctx, config);

        customLog('Se completa ageChart');

    }

    refreshAgeChart() {
        if (!this.chartAge) return;
        //en el grafico de barras, hay 2 datasets, y la info esta en chartAge.data.datasets[0].data
        //datasets[0] = m datasets[1] = f
        customLog('refreshAgeChart, data in chart: ');
        this.chartAge.data.datasets[0].data = this.analitycsAgesData.m;
        this.chartAge.data.datasets[1].data = this.analitycsAgesData.f;
        this.chartAge.update();
        customLog('finalizo refresh');
    }

    // chart de habitantes
    populationChart() {
        customLog('populationChart: inicializacion');
        if (this.chartPopulation) return

        customLog('Se inicia populationChart');
        function sumOfDataVal(dataArray) {
            return dataArray['datasets'][0]['data'].reduce(function (sum, value) {
                return sum + value;
            }, 0);
        }

        const dataResponse = {
            // These labels appear in the legend and in the tooltips when hovering different arcs
            labels: [
                'Hombres',
                'Mujeres'
            ],
            datasets: [{
                data: [this.analitycsGenderData.menSumary, this.analitycsGenderData.womenSumary],
                backgroundColor: [
                    MEN_COLOR,
                    WOMEN_COLOR,
                ],
                borderColor: '#ffffff',
                borderWidth: 4,
                hoverBackgroundColor: [
                    MEN_COLOR,
                    WOMEN_COLOR,
                ],
                hoverBorderColor: '#ffffff',
                hoverBorderWidth: 0
            }]
        };

        this.chartjsTooltip = this.template.querySelector('.chartjsTooltip');

        const customFunction = (tooltip) => {
            // Hide if no tooltip
            if (tooltip.opacity === 0) {
                this.chartjsTooltip.style.color = "#FFFFFF";
                this.chartjsTooltip.querySelector('p').innerHTML = '';

                this.chartjsTooltip.style.opacity = 0;
                return;
            }

            // Set caret Position
            this.chartjsTooltip.classList.remove('above', 'below', 'no-transform');
            if (tooltip.yAlign) {
                this.chartjsTooltip.classList.add(tooltip.yAlign);
            } else {
                this.chartjsTooltip.classList.add('no-transform');
            }

            function getBody(bodyItem) {
                return bodyItem.lines;
            }

            // Set Text
            if (tooltip.body) {
                var bodyLines = tooltip.body.map(getBody);
                var className = bodyLines[0][0].split(":")[0];
                var innerHtml = '<p class="' + className + '">';
                bodyLines.forEach(function (body, i) {
                    var dataNumber = body[i].split(":");
                    var dataValNum = parseInt(dataNumber[1].trim());
                    var dataToPercent = (dataValNum / sumOfDataVal(dataResponse) * 100).toFixed(2) + '%';
                    innerHtml += dataToPercent;
                    innerHtml += '<strong>' + dataNumber[0] + '</strong>';
                });

                innerHtml += '</p>';
                this.chartjsTooltip.querySelector('div').innerHTML = innerHtml;

                // sí, toda esta parte debería estar en el .css, pero no me lo toma
                const color = className == 'Mujeres' ? WOMEN_COLOR : MEN_COLOR;
                this.chartjsTooltip.style.color = color;
                this.chartjsTooltip.querySelector('p').style.fontSize = "15px";
                this.chartjsTooltip.querySelector('p').style.display = "flex";
                this.chartjsTooltip.querySelector('p').style.flexDirection = "column";
                this.chartjsTooltip.querySelector('p').style.alignItems = "center";
                this.chartjsTooltip.querySelector('strong').style.fontSize = "1.1em";
            }

            this.chartjsTooltip.style.opacity = 1;
        }

        const config = {
            type: 'doughnut',
            data: dataResponse,
            options: {
                legend: {
                    display: false
                },
                cutoutPercentage: 73,
                circumference: 2 * Math.PI,
                maintainAspectRatio: false,
                animation: {
                    animateRotate: false,
                    animateScale: true
                },
                tooltips: {
                    enabled: false,
                    custom: customFunction
                },
            }
        }

        let ctx = this.template.querySelector('canvas.populationChart').getContext('2d');
        this.chartPopulation = new Chart(ctx, config);
        customLog('Se completa populationChart');

    }

    refreshPopulationChart() {
        if (!this.chartPopulation) return;
        //en el grafico de dona, los datos terminan en data.dataset[0].data
        //data[0] = m data[1] = f
        customLog('refreshPopulationChart, data in chart: ');
        this.chartPopulation.data.datasets[0].data[0] = this.analitycsGenderData.menSumary;
        this.chartPopulation.data.datasets[0].data[1] = this.analitycsGenderData.womenSumary;
        this.chartPopulation.update();
        customLog('finalizo refresh');
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



    /*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    /*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    /*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


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

    _canvasAge;
    _canvasPopulation;
    chartAge;
    chartPopulation;
    leafletInitialized;
    chartjsLoaded;

    get canvasAge() {
        if (!this._canvasAge) {
            this._canvasAge = this.template.querySelector('canvas.ageChart');
        }
        return this._canvasAge;
    }

    get canvasPopulation() {
        if (!this._canvasPopulation) {
            this._canvasPopulation = this.template.querySelector('canvas.populationChart');
        }
        return this._canvasPopulation;
    }

    handleQueryData(e) {
        this.dataFromAnalytics = { ...e.detail };
        customLog('handleQueryData: ', JSON.stringify(this.dataFromAnalytics));
        customLog('handleQueryData, datos completos');
        this.loadingForNewData = false;
        this.refreshPopulationChart();
        this.refreshAgeChart();
        this.callCharts();
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

        let dataset_name = "EmpatiaTerritory_DS";

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

        let menSumaryFormated = menSumary.toLocaleString('en-US').replace(',', '.');
        let womenSumaryFormated = womenSumary.toLocaleString('en-US').replace(',', '.');
        let totalSumaryFormated = totalSumary.toLocaleString('en-US').replace(',', '.');

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

    handleClickOnWomanStats () {
        customLog('filter f')
        let tempFilterForGender = [];
        tempFilterForGender.push({ filterField: 'Gender__c', filterComparisonValue: 'f', filterComparisonOperator: '==' })
        this.addFilterToAnalytics({ filterArray: tempFilterForGender });
    }

    handleClickOnMenStats () {
        customLog('filter m')
        let tempFilterForGender = [];
        tempFilterForGender.push({ filterField: 'Gender__c', filterComparisonValue: 'm', filterComparisonOperator: '==' })
        this.addFilterToAnalytics({ filterArray: tempFilterForGender });
    }

    get analitycsAgesData() {

        //generos default
        let agesCount_byGender_byAgeRange = {
            m: {},
            f: {}
        };

        this.dataFromAnalytics.Ages.results.forEach(thisResult => {
            if (!agesCount_byGender_byAgeRange[thisResult.Genero]) {
                agesCount_byGender_byAgeRange[thisResult.Genero] = {};
            }
            agesCount_byGender_byAgeRange[thisResult.Genero][thisResult.Audiencia_Generaciones__c] = thisResult.count;
        })


        let pickListValues = PICK_LIST_TO_CHART_LABELS.getPickListValues();

        let tempObj = {
            m: [],
            f: []
        }

        pickListValues.forEach(thisValue => {
            //los generos default los pongo para que no rompa en esta parte
            let mTemp = agesCount_byGender_byAgeRange.m[thisValue] ? agesCount_byGender_byAgeRange.m[thisValue] : 0;
            let fTemp = agesCount_byGender_byAgeRange.f[thisValue] ? agesCount_byGender_byAgeRange.f[thisValue] : 0;
            tempObj.m.push(mTemp);
            tempObj.f.push(fTemp);
        })
        return tempObj;
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

    get incomeRanges() {
        let tempArray = [];

        let ingresosFromAnalitycs = this.dataFromAnalytics.Ingreso.results;

        let ingresoBajo = 0;
        let ingresoMedio = 0;
        let ingresoAlto = 0;

        console.log('ingresosFromAnalitycs', ingresosFromAnalitycs);

        ingresosFromAnalitycs.forEach(thisIngreso => {
            if (thisIngreso.Ingreso === 'Alto' || thisIngreso.Ingreso === 'Muy Alto') {
                ingresoAlto += thisIngreso.count;
            }
            if (thisIngreso.Ingreso === 'Medio') {
                ingresoMedio += thisIngreso.count;
            }
            if (thisIngreso.Ingreso === 'Bajo' || thisIngreso.Ingreso === 'Muy Bajo') {
                ingresoBajo += thisIngreso.count;
            }
        })

        tempArray.push({ "name": "BAJO", "description": "menos de dos SMVM", "image": this.iconIngresoBajo, "value": ingresoBajo.toLocaleString('en-US').replace(',', '.'), filterValues: '["Bajo","Muy Bajo"]' });
        tempArray.push({ "name": "MEDIO", "description": "entre dos y seis SMVM", "image": this.iconIngresoMedio, "value": ingresoMedio.toLocaleString('en-US').replace(',', '.'), filterValues: '["Medio"]' });
        tempArray.push({ "name": "ALTO", "description": "más de seis SMVM", "image": this.iconIngresoAlto, "value": ingresoAlto.toLocaleString('en-US').replace(',', '.'), filterValues: '["Alto","Muy Alto"]' });

        return tempArray;
    }

    handelClick_IngresosItem(event) {
        let filtros = event.currentTarget.dataset.ingresofilters;
        //{filterArray,isBaseFilter,filterLogicalOperator}
        let tempFilters = {
            filterArray: [
                { filterField: 'Ingreso__c', filterComparisonOperator: 'in', filterComparisonValue: filtros }
            ]
        }
        console.log('handelClick_IngresosItem?')
        this.addFilterToAnalytics(tempFilters);
    }

    get occupationTypes() {
        let data = this.dataFromAnalytics.TipoOcu?.results[0] ?? { 'Asalariado': 0, 'Cuenta propia': 0, 'Jubilados y pensionados': 0, 'Sin ocupacion declarada': 0 };

        let tempArray = [];

        tempArray.push({ "name": 'ASALARIADOS', "image": this.iconOcuAsalariado, "value": data['Asalariado'].toLocaleString('en-US').replace(',', '.'), filter: 'OcpAsa' });
        tempArray.push({ "name": 'CUENTAPROPISTAS', "image": this.iconOcuCuentapropista, "value": data['Cuenta propia'].toLocaleString('en-US').replace(',', '.'), filter: 'OcpCue' });
        tempArray.push({ "name": 'JUBILADOS', "image": this.iconOcuJubilado, "value": data['Jubilados y pensionados'].toLocaleString('en-US').replace(',', '.'), filter: 'OcpJub' });
        tempArray.push({ "name": 'SIN INGRESOS DECLARADOS', "image": this.iconOcuSinIngreso, "value": data['Sin ocupacion declarada'].toLocaleString('en-US').replace(',', '.'), filter: 'OcpSinDeclarar' });

        return tempArray;
    }

    handelClick_Ocupation(event) {
        //los filtros tambien podrian ser sobre las nuevas columnas calculadas. Despues habra que ver como queda mas prolijo. 
        let filterValue = event.currentTarget.dataset.ocupationfilter;

        if (filterValue === 'OcpSinDeclarar') {
            let tempFilters = {
                filterArray: [{ filterField: 'condicion_de_ingreso__c', filterComparisonValue: 'null', filterComparisonOperator: 'is' }]
            };
            this.addFilterToAnalytics(tempFilters);
        }

        if (filterValue === 'OcpAsa') {
            let tempFilters = {
                filterArray: [{ filterField: 'condicion_de_ingreso__c', filterComparisonValue: 'Asalariado', filterComparisonOperator: 'matches' }]
            };
            this.addFilterToAnalytics(tempFilters);
        }
        if (filterValue === 'OcpJub') {
            let tempFilters = {
                filterArray: [{ filterField: 'condicion_de_ingreso__c', filterComparisonValue: 'Jubilados y pensionados', filterComparisonOperator: 'matches' }]
            };
            this.addFilterToAnalytics(tempFilters);
        }
        if (filterValue === 'OcpCue') {
            let tempFilters = {
                filterArray: [
                    { filterField: 'condicion_de_ingreso__c', filterComparisonValue: 'Cooperativas y precaria', filterComparisonOperator: 'matches' },
                    { filterField: 'condicion_de_ingreso__c', filterComparisonValue: 'Cuenta propia', filterComparisonOperator: 'matches' }
                ],
                filterLogicalOperator: '||'
            };
            this.addFilterToAnalytics(tempFilters);
        }
    }

    get educationLevels() {
        let tempArray = [];

        let educationFromAnalitycs = this.dataFromAnalytics.Education.results;

        let primario = 0;
        let secundario = 0;
        let terciario = 0;
        let universitario = 0;

        educationFromAnalitycs.forEach(thisEducacion => {
            if (thisEducacion.Education.toUpperCase().includes('PRIMARIO')) {
                primario += thisEducacion.count;
            }
            if (thisEducacion.Education.toUpperCase().includes('SECUNDARIO')) {
                secundario += thisEducacion.count;
            }
            if (thisEducacion.Education.toUpperCase().includes('TERCIARIO')) {
                terciario += thisEducacion.count;
            }
            if (thisEducacion.Education.toUpperCase().includes('UNIVERSITARIO')) {
                universitario += thisEducacion.count;
            }
        })

        tempArray.push({ "name": "Primario completo", "image": this.iconEduPrimaria, "value": primario.toLocaleString('en-US').replace(',', '.'), educationfilter: 'Primario' });
        tempArray.push({ "name": "Secundario completo", "image": this.iconEduSecundaria, "value": secundario.toLocaleString('en-US').replace(',', '.'), educationfilter: 'Secundario' });
        tempArray.push({ "name": "Terciario completo / univ. incompleto", "image": this.iconEduTerciaria, "value": terciario.toLocaleString('en-US').replace(',', '.'), educationfilter: 'Terciario' });
        tempArray.push({ "name": "Universitario completo", "image": this.iconEduUniversitaria, "value": universitario.toLocaleString('en-US').replace(',', '.'), educationfilter: 'Universitario' });

        return tempArray;
    }

    handelClick_Education(event) {
        let filtros = event.currentTarget.dataset.educationfilter;
        let tempFilters = {
            filterArray: [
                { filterField: 'Education_Level__c', filterComparisonOperator: 'matches', filterComparisonValue: filtros }
            ]
        }
        console.log('handelClick_Education')
        this.addFilterToAnalytics(tempFilters);
    }

    get actividadesEconomicas() {
        let data = {
            ...ACTIVIDADES_ECONOMICAS_DEFAULT
        };

        let queryData = this.dataFromAnalytics.ActEco?.results[0];

        if (queryData) {
            data = {
                ...queryData
            };
        }

        console.log('ACTIVIDADES ENCONOMICAS: ', data)
        let tempArray = [];

        Object.entries(data).forEach(([key, value]) => {
            tempArray.push({
                "image": this.iconEmpleado,
                "name": key,
                "value": value,
                "actividadfilter": key
            })

        });


        let sortedArray = tempArray.sort((a, b) => { return b.value - a.value });

        sortedArray.forEach(thisElement => {
            thisElement.value = thisElement.value.toLocaleString('en-US').replace(',', '.')
        })

        return sortedArray;
    }

    handelClick_Actividades(event) {
        let filtros = event.currentTarget.dataset.actividadfilter;
        //{filterArray,isBaseFilter,filterLogicalOperator}
        let tempFilters = {
            filterArray: [
                { filterField: 'actividades_economicas__c', filterComparisonOperator: 'matches', filterComparisonValue: filtros }
            ]
        }
        console.log('handelClick_Actividades')
        this.addFilterToAnalytics(tempFilters);
    }

    get showActividadesEconomicas() {
        return (this.actividadesEconomicas.length > 0);
    }

    get showGeographicDistribution() {
        return (this.geographicDistribution.length > 0);
    }

    get geographicDistribution() {
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
            thisElement.value = thisElement.value.toLocaleString('en-US').replace(',', '.')
        })

        return tempArray;
    }

    handelClick_PopulationChart(e) {
        var activePoints = this.chartPopulation.getElementsAtEvent(e);
        customLog('click on canvas: ')
        customLog('click on canvas: ', activePoints)
        // active points esta devolviendo un array. Para el grafico circular, siempre de length == 1.
        // el unico elemento es un objeto y contiene una propiedad "_index". Esa propiedad es el index del array que se uso para ese segmento de circulo.
        if (activePoints.length === 0) {
            return;
        }
        customLog('paso check de lenght: ')
        let tempFilterForGender = [];
        if (activePoints[0]._index === 0) {
            //hombres
            tempFilterForGender.push({ filterField: 'Gender__c', filterComparisonValue: 'm', filterComparisonOperator: '==' })
            customLog('filter m')
        }

        if (activePoints[0]._index === 1) {
            //mujeres
            tempFilterForGender.push({ filterField: 'Gender__c', filterComparisonValue: 'f', filterComparisonOperator: '==' })
            customLog('filter f')
        }

        this.addFilterToAnalytics({ filterArray: tempFilterForGender });
    }

    //por ahora, un solo filtro por grafico
    lastFilterApplied;

    handelClick_AgesChart(event) {
        customLog('click on canvas age: ')

        const clickedElementsArray = this.chartAge.getElementsAtEventForMode(event, 'nearest', { intersect: true, axis: 'x' }, false);

        let generatedFilters;

        if (clickedElementsArray.length !== 0) {
            generatedFilters = handleClickIn_ColumnSection(clickedElementsArray[0]);
        } else {
            generatedFilters = handleClickIn_ChartWhiteArea(event, this.chartAge);
        }

        const filterToApply_string = JSON.stringify(generatedFilters);

        const existeFiltroPrevio = Boolean(this.lastFilterApplied);
        const seToggleaFiltro = this.lastFilterApplied === filterToApply_string;

        if (existeFiltroPrevio && !seToggleaFiltro) return;

        this.addFilterToAnalytics(generatedFilters);

        if (!existeFiltroPrevio) {
            this.lastFilterApplied = filterToApply_string
        }
        if (seToggleaFiltro) {
            this.lastFilterApplied = null;
        }

    }

    addFilterToAnalytics(filter) {
        this.loadingForNewData = true;
        this.analitycsManager.toggleTemporaryFilter(filter);
        console.log('added filters?')
    }

}

function handleClickIn_ColumnSection(clickedElement) {
    customLog('clickeo una seleccion')
    const datasetLabel = clickedElement._model.datasetLabel
    const xAxisLabel = clickedElement._model.label;

    let genderFilter;

    if (datasetLabel === 'Hombres') {
        genderFilter = 'm'
    }

    if (datasetLabel === 'Mujeres') {
        genderFilter = 'f'
    }

    let audienciaFilter = PICK_LIST_TO_CHART_LABELS.array.filter(thisElement => {
        return (thisElement.chartLabel.flat().join('') === xAxisLabel.flat().join(''))
    });

    audienciaFilter = audienciaFilter[0].pickListValue;

    customLog('datos: ', genderFilter + ' - ' + audienciaFilter);

    let tempFilter = [];

    tempFilter.push({ filterField: 'Gender__c', filterComparisonValue: genderFilter, filterComparisonOperator: '==' });
    tempFilter.push({ filterField: 'Audiencia_Generaciones__c', filterComparisonValue: audienciaFilter, filterComparisonOperator: '==' });

    return {
        filterArray: tempFilter,
        filterLogicalOperator: '&&'
    };

}

function handleClickIn_ChartWhiteArea(event, chartAgeChart) {
    const clickedColumn = chartAgeChart.getElementsAtEventForMode(event, 'nearest', { intersect: false, axis: 'x' }, false);

    let audienciaFilter = PICK_LIST_TO_CHART_LABELS.array.filter(thisElement => {
        console.log('flat array?: ', thisElement.chartLabel.flat().join(''));
        console.log('columna?: ', clickedColumn[0]._model.label.join(''));
        return (thisElement.chartLabel.flat().join('') === clickedColumn[0]._model.label.join(''))
    });

    audienciaFilter = audienciaFilter[0].pickListValue;

    let tempFilter = [];

    tempFilter.push({ filterField: 'Audiencia_Generaciones__c', filterComparisonValue: audienciaFilter, filterComparisonOperator: '==' });

    return {
        filterArray: tempFilter
    }
}