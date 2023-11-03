import { LightningElement, api, track, wire } from 'lwc';
import retrieveTerritory from '@salesforce/apex/TerritoryDetailController.retrieveTerritory';
import getTerritoryById from '@salesforce/apex/TerritoryDetailController.getTerritoryById';
import Resources from '@salesforce/resourceUrl/Communities';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

import lblInhabitants from '@salesforce/label/c.PRM_Inhabitants';
import lblWomen from '@salesforce/label/c.PRM_Women';
import lblMen from '@salesforce/label/c.PRM_Men';
import lblEducationLevel from '@salesforce/label/c.PRM_Education_Level';
import lblIncomeRange from '@salesforce/label/c.PRM_Income_Range';
import lblOccupationType from '@salesforce/label/c.PRM_Occupation_Type';
import lblEconomicActivities from '@salesforce/label/c.PRM_Economic_Activities';
import lblGeographicDistribution from '@salesforce/label/c.PRM_Greographic_Distribution';
import lblTerritory from '@salesforce/label/c.PRM_Territory';
import lblAdministrativeLevel from '@salesforce/label/c.PRM_Administrative_Level';
import lblParentTerritory from '@salesforce/label/c.PRM_Parent_Territory';
import smvm from '@salesforce/label/c.SMVM';

// LEAFLET
import leaflet from '@salesforce/resourceUrl/Leafleat';
// AOS
import aos from '@salesforce/resourceUrl/AOS_JS_Library';
// ChartJS
import chartjs from '@salesforce/resourceUrl/ChartJS';

export default class Empatia_territoryFullPage extends LightningElement {
    recordcount = 5;
    
    // @api recordId = "a2L1h000000EO1tEAG"; // Vicente Lopez
    // @api recordId = 'a2L1h000000E5V4EAK'; // William Morris
    // @api community = "Prosumia";
    // @api currentPage = "Community";

    @api recordId;
    @api community;
    @api currentPage;
    @track territoryWrapper;
    @track nivelAdministrativo0 = false;
    @track nivelAdministrativo1 = false;
    @track nivelAdministrativo2 = false;
    @track nivelAdministrativo3 = false;
    @track nivelAdministrativo4 = false;
    @track totalMen = 0;
    @track totalWomen = 0;
    @track array_adminLevel;

    label = {
        lblInhabitants,
        lblWomen,
        lblMen,
        lblEducationLevel,
        lblIncomeRange,
        lblOccupationType,
        lblEconomicActivities,
        lblGeographicDistribution,
        lblTerritory,
        lblAdministrativeLevel,
        lblParentTerritory,
        smvm
    };

    @track isRecordReady;
    @track isWrapperReady = false;
    @track territoryInfo = {};
    @track geographicdistributions = [];
    @track isgeographicdistributionsbuttonvisible = false;
    @track educationLevels = [];
    @track incomeranges = [];
    @track occupationTypes = [];
    @track title = '';
    @track subtitle = '';
    @track subtitlelinktext = '';
    @track subtitlelinkurl = '';

    // DEFINE ICONS
    iconRight = Resources + '/SALESFORCE/img/Territories/arrowrightps.svg';
    @track iconTerritories = '';
    @track iconMarker = '';
    @track iconMapMarker = '';
    @track iconIngresoBajo = '';
    @track iconIngresoMedio = '';
    @track iconIngresoAlto = '';
    @track iconOcuAsalariado = '';
    @track iconOcuCuentapropista = '';
    @track iconOcuJubilado = '';
    @track iconOcuSinIngreso = '';
    @track iconEduPrimaria = '';
    @track iconEduSecundaria = '';
    @track iconEduTerciaria = '';
    @track iconEduUniversitaria = '';
    @track iconEmpleado = '';

    @track renderEducation = false;
    @track renderIncomeRange = false;
    @track renderOccupationType = false;
    @track renderEconomicActivities = false;
    @track lstEconomicActivities = [];

    @track showMap = true;
    @track showGeographicDistribution = false;
    @track showEconomicActivities = false;

    @track percentageWomen = 0;
    @track percentageMen = 0;
    @track womenCount = [];
    @track menCount = [];

    // @track charttext = '';
    @track chartjsTooltip = ''

    @track context = null;

    @track ORIGIN_PAGE = window.location.href.substring(0, window.location.href.indexOf('/s/'));
    @track URL_GEOLOCATION = 'https://nominatim.openstreetmap.org/search?format=json&limit=3';

    isChartJsInitialized = false;

    @track sticky_class = "sticky_container";
    @track all_page_class = "all-page";

    connectedCallback() {
        console.log("ConnectedCallback");
        console.log("recordId", this.recordId);
        // window.addEventListener('resize', this.callCharts());

        // this.template.addEventListener("ready", (e) => {
        //     console.log("ready event dispatched");
        // });
        window.addEventListener('scroll', (evt) => {
            this.template.querySelectorAll("[data-aos]").forEach((elem) => {
                if (this.element_is_visible(elem)) {
                    elem.classList.add("aos-init", "aos-animate");
                }
            });
        });

        // Agrego la clase .CRM a los componentes que lo requieran
        // console.log('recordId: ', this.recordId);
        // console.log('community: ', this.community);
        // console.log('current page: ', this.currentPage);
        this.sticky_class += " " + this.currentPage;
        this.all_page_class += " " + this.currentPage;

        if (window.location.href.includes('lightning/r/Territorio_Administrativo__c')) {
            this.context = 'crm';
        } else {
            this.context = 'community';
        }
    }

    callCharts(){
        try{
            if(this.isRecordReady){
                this.ageChart();
                this.populationChart();
            }
        }catch(error){
            console.log(error);
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

    disconnectedCallback() {
    }

    renderedCallback() {
        console.log("renderedCallback");
        
        this.loadAOS();
        this.loadLeafletJS();
        // this.getComponents();
        this.loadChartJS();


        console.log('renderedCallback [] <-');
    }

    loadAOS(){
        // LOAD AOS
        loadStyle(this, aos + '/aos.css').then(() => {
            loadScript(this, aos + '/aos.js').then(() => {
                console.log("calling AOS_init");
                this.AOS_init();
                this.template.querySelectorAll("[data-aos]").forEach((elem) => {
                    if (this.element_is_visible(elem))
                        elem.classList.add("aos-init", "aos-animate");
                });
            });
        });
    }

    loadChartJS(){
        if (this.isChartJsInitialized) {
            return;
        }
        // LOAD CHART JS
        loadScript(this, chartjs + '/Chart.bundle.min.js')
            .then(() => {
                this.isChartJsInitialized = true;
                console.log('Dibujo charts');
                // this.peopleChart();
                this.ageChart();
                this.populationChart();
            })
            .catch(error => console.log(error));
    }

    loadLeafletJS(){
        // LOAD LEAFLET JS
        console.log('renderingMap [] ->');
        Promise.all([
            loadScript(this, leaflet + '/leaflet.js'),
            loadStyle(this, leaflet + '/leaflet.css')
        ]).then(() => {
            console.log('initializeleaflet [recordId : ' + this.recordId + ' - community : ' + this.community + ']');
            // console.log('recibido territory?', this.territoryInfo);
            // this.initializeleaflet(this.territoryInfo);
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

    @wire(retrieveTerritory, {strTerritoryId: '$recordId', strCommunity: '$community'})
    wiredTerritory({ error, data }) {
        if (data) {
            console.log("Retrieving Data....");
            console.log('context = ', this.context);
            this.isRecordReady = false;
            this.territoryInfo = data;
            console.log('TERRITORY INFO: ', this.territoryInfo);

            // ICONS ASSIGNMENT
            this.iconTerritories = Resources + '/SALESFORCE/img/Territories/territorio.svg';
            this.iconMarker = Resources + '/SALESFORCE/img/Territories/marker.svg';
            this.iconMapMarker = Resources + '/SALESFORCE/img/Territories/territorio.svg';
            this.iconIngresoBajo = Resources + '/SALESFORCE/img/Territories/indicador_bajo.svg';
            this.iconIngresoMedio = Resources + '/SALESFORCE/img/Territories/indicador_medio.svg';
            this.iconIngresoAlto = Resources + '/SALESFORCE/img/Territories/indicador_alto.svg';
            this.iconOcuAsalariado = Resources + '/SALESFORCE/img/Territories/icon_asalariado.svg';
            this.iconOcuCuentapropista = Resources + '/SALESFORCE/img/Territories/icon_cuentaprop.svg';
            this.iconOcuJubilado = Resources + '/SALESFORCE/img/Territories/icon_jubilado.svg';
            this.iconOcuSinIngreso = Resources + '/SALESFORCE/img/Territories/icon_siningresos.svg';
            this.iconEduPrimaria = Resources + '/SALESFORCE/img/Territories/ne_primario.svg';
            this.iconEduSecundaria = Resources + '/SALESFORCE/img/Territories/ne_secundario.svg';
            this.iconEduTerciaria = Resources + '/SALESFORCE/img/Territories/ne_universitario.svg';
            this.iconEduUniversitaria = Resources + '/SALESFORCE/img/Territories/ne_universitario_completo.svg';
            this.iconEmpleado = Resources + '/SALESFORCE/img/Territories/ae_empleado.svg';

            this.renderEducation = this.territoryInfo.educationLevels.length > 0;
            this.renderIncomeRange = this.territoryInfo.incomeranges.length > 0;;
            this.renderOccupationType = this.territoryInfo.occupationTypes.length > 0;
            this.renderEconomicActivities = this.territoryInfo.economicactivities.length > 0;

            if(this.renderEducation || this.renderIncomeRange || this.renderOccupationType || this.renderEconomicActivities ) {
                this.renderEducation = true;
                this.renderIncomeRange = true;
                this.renderOccupationType = true;
                this.renderEconomicActivities = true;                        
            }

            // console.log("Actividades Economicas : ", this.territoryInfo.economicactivities);
            for (var ea of this.territoryInfo.economicactivities) {
                this.lstEconomicActivities.push({"image": this.iconEmpleado, "value": ea.info.value, "name": ea.info.name, "description": ea.info.description});
            }
            this.lstEconomicActivities.sort(function(a,b){return parseInt(b.value.replaceAll('.','')) - parseInt(a.value.replaceAll('.',''))});
            this.showEconomicActivities = this.lstEconomicActivities.length>0 ? true : false;

            if(this.territoryInfo.geographicdistributions !== undefined && this.territoryInfo.geographicdistributions !== null) {
                if(this.territoryInfo.geographicdistributions.length > 0) {
                    // console.log('porque pasa 3 veces!');
                    console.log(this.territoryInfo.geographicdistributions);
                    // this.geographicdistributions = this.territoryInfo.geographicdistributions.slice(0, this.recordcount);


                    for (var gd of this.territoryInfo.geographicdistributions) {
                        let splits = gd.info.link.split('/');
                        let id = splits[splits.length - 1];
                        console.log('ID de GD', id);
                        console.log('ORIGIN_PAGE:', this.ORIGIN_PAGE);

                        let link = this.ORIGIN_PAGE;

                        // if(gd.info.link.includes('/prosumia/')){
                        if(this.context == 'community'){
                            link += '/s/territorio-administrativo/' + id;
                        } else {
                            link += '/lightning/r/Territorio_Administrativo__c/' + id + '/view';
                        }
                        this.geographicdistributions.push({ "id" : id, "description": gd.info.description, "image": gd.info.image, "link": link, "name": gd.info.name, "value": gd.info.value });
                    }

                    this.isgeographicdistributionsbuttonvisible = true;
                    this.showGeographicDistribution = true;
                } else {
                    this.showGeographicDistribution = false;
                    this.isgeographicdistributionsbuttonvisible = false;
                    this.geographicdistributions = this.territoryInfo.geographicdistributions; 
                }
            } else {
                this.showGeographicDistribution = false;
            }
            console.log('this.territoryInfo.geographicdistributions', this.territoryInfo.geographicdistributions)

            
            // this.iconPeople = Resources + '/' + this.community + '/img/IconPeople.png';
            // console.log('iconPeople: ' + this.iconPeople);

            this.title = this.territoryInfo.name;
            
            if(this.territoryInfo.parentid !== undefined && this.territoryInfo.parentid !== null && this.territoryInfo.parentid.length > 0) {
                this.subtitle = this.label.lblTerritory + ',  ' + this.label.lblAdministrativeLevel + ' ' + this.territoryInfo.administrativelevel + ', ' + this.label.lblParentTerritory;
                this.subtitlelinktext = this.territoryInfo.parent;
                
                this.subtitlelinkurl = this.territoryInfo.parentlink;
            } else {
                this.subtitle = this.label.lblTerritory + ', ' + this.label.lblAdministrativeLevel + ' ' + this.territoryInfo.administrativelevel;
            }

            // education levels
            this.educationLevels.push({"description": "Primario completo","image": this.iconEduPrimaria,"name": this.territoryInfo.educationLevels[0].info.name,"value":this.territoryInfo.educationLevels[0].info.value});
            this.educationLevels.push({"description": "Secundario completo","image": this.iconEduSecundaria,"name": this.territoryInfo.educationLevels[1].info.name,"value":this.territoryInfo.educationLevels[1].info.value});
            this.educationLevels.push({"description": "Terciario completo / univ. incompleto","image": this.iconEduTerciaria,"name": this.territoryInfo.educationLevels[2].info.name,"value":this.territoryInfo.educationLevels[2].info.value});
            this.educationLevels.push({"description": "Universitario completo","image": this.iconEduUniversitaria,"name": this.territoryInfo.educationLevels[3].info.name,"value":this.territoryInfo.educationLevels[3].info.value});
            // console.log('educationLevels',this.educationLevels);

            // let test = this.territoryInfo.incomeranges[0].info.value.replace(/\./g, '');
            let strIngresoMuyBajo = this.territoryInfo.incomeranges[0].info.value.replace(/\./g, '');
            let strIngresoBajo = this.territoryInfo.incomeranges[1].info.value.replace(/\./g, '');
            let strIngresoMedio = this.territoryInfo.incomeranges[2].info.value.replace(/\./g, '');
            let strIngresoAlto = this.territoryInfo.incomeranges[3].info.value.replace(/\./g, '');
            let strIngresoMuyAlto = this.territoryInfo.incomeranges[4].info.value.replace(/\./g, '');

            // console.log('test', test);
            // console.log('strIngresoMuyBajo',strIngresoMuyBajo);
            // console.log('strIngresoBajo', strIngresoBajo);
            // console.log('strIngresoMedio', strIngresoMedio);
            // console.log('strIngresoAlto', strIngresoAlto);
            // console.log('strIngresoMuyAlto',strIngresoMuyAlto);

            // income ranges
            this.incomeranges.push({"name": "BAJO","description": "menos de dos SMVM", "image": this.iconIngresoBajo, "value": (parseInt(strIngresoMuyBajo) + parseInt(strIngresoBajo)).toLocaleString()});
            this.incomeranges.push({"name": "MEDIO","description": "entre dos y seis SMVM", "image": this.iconIngresoMedio, "value": (parseInt(strIngresoMedio)).toLocaleString()});
            this.incomeranges.push({"name": "ALTO","description": "más de seis SMVM", "image": this.iconIngresoAlto, "value": (parseInt(strIngresoAlto) + parseInt(strIngresoMuyAlto)).toLocaleString()});
            // console.log('income ranges:', this.incomeranges);

            // occupation types
            this.occupationTypes.push({"name": "ASALARIADOS", "image": this.iconOcuAsalariado, "description": this.territoryInfo.occupationTypes[0].info.description, "value": this.territoryInfo.occupationTypes[0].info.value});
            this.occupationTypes.push({"name": "CUENTAPROPISTAS", "image": this.iconOcuCuentapropista, "description": this.territoryInfo.occupationTypes[1].info.description, "value": this.territoryInfo.occupationTypes[1].info.value});
            this.occupationTypes.push({"name": "JUBILADOS", "image": this.iconOcuJubilado, "description": this.territoryInfo.occupationTypes[2].info.description, "value": this.territoryInfo.occupationTypes[2].info.value});
            this.occupationTypes.push({"name": "SIN INGRESOS DECLARADOS", "image": this.iconOcuSinIngreso, "description": this.territoryInfo.occupationTypes[3].info.description, "value": this.territoryInfo.occupationTypes[3].info.value});
            // console.log("occupationTypes:", this.occupationTypes);
            
            this.error = undefined;
        } else if (error) {
            this.error = error;
            console.log("hubo un error en el wire D:")
        }
        this.isRecordReady = true;
    }

    @wire(getTerritoryById, { territoryId: '$recordId' })
    wiredTerritory2({ error, data }) {
        if (data) {
            this.isWrapperReady = false;
            console.log('TERRITORY WRAPPER:', data);
            this.territoryWrapper = data;

            // set nivel adminitrativo
            if(this.territoryWrapper.territory.Nivel_Administrativo__c===0){
                this.nivelAdministrativo0 = true;
            } else if(this.territoryWrapper.territory.Nivel_Administrativo__c===1){
                this.nivelAdministrativo1 = true;
            } else if(this.territoryWrapper.territory.Nivel_Administrativo__c===2){
                this.nivelAdministrativo2 = true;
            } else if(this.territoryWrapper.territory.Nivel_Administrativo__c===3){
                this.nivelAdministrativo3 = true;
            } else if(this.territoryWrapper.territory.Nivel_Administrativo__c===4){
                this.nivelAdministrativo4 = true;
            }
            
            // set array_adminLevel
            let admLevelLink = '';
            if (this.context == 'community') {
                admLevelLink = this.ORIGIN_PAGE + '/s/territorio-administrativo/';
            } else {
                admLevelLink = this.ORIGIN_PAGE + '/lightning/r/Territorio_Administrativo__c/';
            }
            this.array_adminLevel = [];
            if(this.territoryWrapper.ter1.Name && !this.nivelAdministrativo1){
                this.array_adminLevel.push({ "id": this.territoryWrapper.ter1.Id, "name":this.territoryWrapper.ter1.Name, "link":admLevelLink+this.territoryWrapper.ter1.Id+'/view', "isLast":false })
            }
            if(this.territoryWrapper.ter2.Name && !this.nivelAdministrativo2){
                this.array_adminLevel.push({ "id": this.territoryWrapper.ter2.Id, "name":this.territoryWrapper.ter2.Name, "link":admLevelLink+this.territoryWrapper.ter2.Id+'/view', "isLast":false })
            }
            if(this.territoryWrapper.ter3.Name && !this.nivelAdministrativo3){
                this.array_adminLevel.push({ "id": this.territoryWrapper.ter3.Id, "name":this.territoryWrapper.ter3.Name, "link":admLevelLink+this.territoryWrapper.ter3.Id+'/view', "isLast":false })
            }
            if(this.territoryWrapper.ter4.Name && !this.nivelAdministrativo4){
                this.array_adminLevel.push({ "id": this.territoryWrapper.ter4.Id, "name":this.territoryWrapper.ter4.Name, "link":admLevelLink+this.territoryWrapper.ter4.Id+'/view', "isLast":false })
            }
            if(this.array_adminLevel.length>0){
                this.array_adminLevel[(this.array_adminLevel.length)-1].isLast = true;
            }

            console.log('ADMIN ARRAY:', this.array_adminLevel);
            // console.log('ADMIN ARRAY LENGH:', this.array_adminLevel.length);


            // calculate percentage
            this.percentageWomen = parseFloat(this.territoryWrapper.totalWomenPerc ? this.territoryWrapper.totalWomenPerc : 0).toFixed(2);
            this.percentageMen = parseFloat(this.territoryWrapper.totalMenPerc ? this.territoryWrapper.totalMenPerc : 0).toFixed(2);

            this.totalWomen = this.territoryWrapper.totalWomen;
            this.totalMen = this.territoryWrapper.totalMen;
            this.womenCount = [
                this.territoryWrapper.territory.Etario_Sub_16_Female__c,
                this.territoryWrapper.territory.Etario_Centennials_Female__c,
                this.territoryWrapper.territory.Etario_Millennials_Female__c,
                this.territoryWrapper.territory.Etario_Generacion_X_Female__c,
                this.territoryWrapper.territory.Etario_Baby_Boomers_Female__c,
                this.territoryWrapper.territory.Etario_Generacion_Silenciosa_Female__c
            ];
            this.menCount = [
                this.territoryWrapper.territory.Etario_Sub_16_Male__c,
                this.territoryWrapper.territory.Etario_Centennials_Male__c,
                this.territoryWrapper.territory.Etario_Millennials_Male__c,
                this.territoryWrapper.territory.Etario_Generacion_X_Male__c,
                this.territoryWrapper.territory.Etario_Baby_Boomers_Male__c,
                this.territoryWrapper.territory.Etario_Generacion_Silenciosa_Male__c
            ];

            this.isWrapperReady = true;

            // this.loadAOS();
            this.callCharts();
            // console.log('recibido territory?', this.territoryWrapper);
            this.initializeleaflet();

            // console.log('Territory Wrapper: ', this.territoryWrapper);
            this.error = undefined;
        } else if (error) {
            console.error(error);
            console.error('error.name => ' + error.name );
            console.error('error.message => ' + error.message );
            console.error('error.stack => ' + error.stack );
            this.error = error;
            this.territoryWrapper = undefined;
        }
    }

    AOS_init() {
        console.log("initting AOS");
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

    }

    // chart de distribución etaria
    ageChart(){
        const dataResponse = {
            // These labels appear in the legend and in the tooltips when hovering different arcs
            labels: [
                'Sub 16',
                'Centenials',
                'Milenials',
                'Generación X',
                'Baby Boomers X',
                'Generación Silenciosa',
            ],
            datasets: [
                {
                    label :'Hombres',
                    data : [this.menCount[0], this.menCount[1], this.menCount[2], this.menCount[3], this.menCount[4], this.menCount[5]],
                    backgroundColor:'#0082be',
                    stack: 'Stack 0',
                }, {
                    label :'Mujeres',
                    data : [this.womenCount[0], this.womenCount[1], this.womenCount[2], this.womenCount[3], this.womenCount[4], this.womenCount[5]],
                    backgroundColor:'#885493',
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
                ,plugins: {
                    title: {
                        display: false
                    },
                    legend: false,
                    tooltip: false,
                }
                ,layout: {
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
                            callback: function(label, index, labels) {
                                if(label>1000000){
                                    return label/1000000+' millones';
                                }else if(label>1000){
                                    var miles = label/1000 < 1000 ? ' miles' : ' millón';
                                    var cantidad = label/1000 < 1000 ? label/1000 : label/1000000;
                                    return cantidad+miles;
                                }else{
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
            }
        }
    
        let ctx = this.template.querySelector('canvas.ageChart').getContext('2d');
        this.chart_age = new Chart(ctx, config);
    }

    // chart de habitantes
    populationChart(){
        function sumOfDataVal(dataArray) {
            return dataArray['datasets'][0]['data'].reduce(function (sum, value) {
                return sum + value;
            }, 0);
        }
    
        const dataResponse = {
            // These labels appear in the legend and in the tooltips when hovering different arcs
            labels: [
                'Mujeres',
                'Hombres'
            ],
            datasets: [{
                data: [this.totalWomen, this.totalMen],
                backgroundColor: [
                    '#885493',
                    '#0082be'
                    ],
                borderColor: '#ffffff',
                borderWidth: 4,
                hoverBackgroundColor: [
                    '#885493',
                    '#0082be'
                ],
                hoverBorderColor: '#ffffff',
                hoverBorderWidth: 0
            }]
        };

        this.chartjsTooltip = this.template.querySelector('.chartjsTooltip');
        // console.log('chartjsTooltip',this.chartjsTooltip);

        const customFunction =  ( tooltip ) => {
            console.log('tooltip',tooltip);
            // Hide if no tooltip
            if (tooltip.opacity === 0) {
                this.chartjsTooltip.style.color = "#FFFFFF";
                this.chartjsTooltip.querySelector('p').innerHTML = '';
                // console.log('entro en opacidad?');

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
                console.log(bodyLines);
                var className = bodyLines[0][0].split(":")[0];
                var innerHtml = '<p class="'+className+'">';
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
                const color = className=='Mujeres'? '#885493' : '#0082be';
                this.chartjsTooltip.style.color = color;
                this.chartjsTooltip.querySelector('p').style.fontSize = "15px";
                this.chartjsTooltip.querySelector('p').style.display = "flex";
                this.chartjsTooltip.querySelector('p').style.flexDirection = "column";
                this.chartjsTooltip.querySelector('p').style.alignItems = "center";
                this.chartjsTooltip.querySelector('strong').style.fontSize = "1.1em";
            }
            
            this.chartjsTooltip.style.opacity = 1;

            // console.log('llego hasta el FINAL?');
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
                // onHover: function(tooltip) {
                //     console.log(tooltip);
                //     let x = document.querySelector('.chartjs-tooltip');
                //     console.log(x);
                // }
            }
        }
    
        let ctx = this.template.querySelector('canvas.populationChart').getContext('2d');
        this.chart_population = new Chart(ctx, config);
    }

    initializeleaflet() {
        var strAddress = null;
        var strUrl = null;
        var strCity = null;
        var strCounty = null;
        var strState = null;
        var strCountry = null;

        if(this.nivelAdministrativo4){
            strAddress = '&q=\'' + this.territoryWrapper.ter4.Name + ', ' +  this.territoryWrapper.ter3.Name + ', ' +  this.territoryWrapper.ter2.Name + ', ' +  this.territoryWrapper.ter1.Name + ', ' + this.territoryWrapper.ter0.Name + '\'';
        } else if(this.nivelAdministrativo3){
            strCity = this.territoryWrapper.ter3.Name;
            strCounty = this.territoryWrapper.ter2.Name;
            strState = this.territoryWrapper.ter1.Name;
            strCountry = this.territoryWrapper.ter0.Name;
            strAddress = '&city=' + strCity + '&county=' + strCounty + '&state=' + strState + '&country=' + strCountry;

        } else if(this.nivelAdministrativo2){
            strCounty = this.territoryWrapper.ter2.Name;
            strState = this.territoryWrapper.ter1.Name;
            strCountry = this.territoryWrapper.ter0.Name;
            strAddress = '&county=' + strCounty + '&state=' + strState + '&country=' + strCountry;

        } else if(this.nivelAdministrativo1){
            strState = this.territoryWrapper.ter1.Name;
            strCountry = this.territoryWrapper.ter0.Name;
            strAddress = '&state=' + strState + '&country=' + strCountry;

        } else if(this.nivelAdministrativo0){
            strCountry = this.territoryWrapper.ter0.Name;
            strAddress = '&country=' + strCountry;

        } else {
            strAddress = '&q=\'' + this.territoryWrapper.territory.Name + '\'';
        }

        // strUrl = this.URL_GEOLOCATION + strAddress;

        // console.log('STR ADDRESS: ', strAddress);
        // console.log('STR URL: ', strUrl);
        
		
		this.drawingMap(strAddress);

        // this.getComponents();
    }

    drawingMap(strAddress){
        var strUrl = this.URL_GEOLOCATION + strAddress;

        console.log('STR ADDRESS: ', strAddress);
        console.log('STR URL: ', strUrl);
        
        var dblLatitude = null;
		var dblLongitude = null;
		var objMap = null;
        var intZoom = 8;
        var maxZoom = 18;

        fetch(strUrl).then((objResponse) => objResponse.json()).then((objData) => {
            if(objData !== undefined && objData !== null && objData.length > 0) {

                console.log('esto dibujo en mapa:',objData)
                
                // dblLatitude  = objData[0].lat;
                // dblLongitude = objData[0].lon;
                dblLatitude  = (parseFloat(objData[0].boundingbox[0]) + parseFloat(objData[0].boundingbox[1])) / 2;
                dblLongitude = (parseFloat(objData[0].boundingbox[2]) + parseFloat(objData[0].boundingbox[3])) / 2;

                const mapRoot = this.template.querySelector(".map_container");
                objMap = L.map(mapRoot, {tap:false}).setView([dblLatitude, dblLongitude], intZoom)
                
                // objMap.fitBounds();
                var myPoints = [[objData[0].boundingbox[0], objData[0].boundingbox[2]], [objData[0].boundingbox[1], objData[0].boundingbox[3]]];
                console.log('PUNTOS:', myPoints);
                // var myBounds = new L.LatLngBounds(myPoints);
                // console.log('BOUNDS:', myBounds);
                // objMap.fitBounds(myPoints);
                // var group = new L.featureGroup(myPoints);
                objMap.fitBounds(myPoints);
        
                var CartoDB_Positron = L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
                    attribution: '&copy; ' + this.community,
                    subdomains: 'abcd',
                    maxZoom: maxZoom
                }).addTo(objMap);

                var greenIcon = L.icon({
                    iconUrl: this.iconMarker,
                    // shadowUrl: RESOURCES + '/' + this.community_site + '/img/mail.svg',
                    iconSize:     [55, 60], // size of the icon
                    // shadowSize:   [50, 64], // size of the shadow
                    iconAnchor:   [50, 50], // point of the icon which will correspond to marker's location
                    // shadowAnchor: [4, 62],  // the same for the shadow
                    popupAnchor:  [-3, -56] // point from which the popup should open relative to the iconAnchor
                });

                L.marker([dblLatitude, dblLongitude], {icon: greenIcon}).addTo(objMap).bindPopup(this.territoryWrapper.territory.Name);
                this.showMap = true;

            } else {
                this.showMap = false;
                // intZoom -= 2;
                // strAddress = strAddress.slice(1 , strAddress.length); 
                var strTerr4 = this.territoryWrapper.ter4.Name ? this.territoryWrapper.ter4.Name : '';
                var strTerr3 = this.territoryWrapper.ter3.Name ? this.territoryWrapper.ter3.Name : '';
                var strTerr2 = this.territoryWrapper.ter2.Name ? this.territoryWrapper.ter2.Name : '';
                var strTerr1 = this.territoryWrapper.ter1.Name ? this.territoryWrapper.ter1.Name : '';
                var strTerr0 = this.territoryWrapper.ter0.Name ? this.territoryWrapper.ter0.Name : '';
                if(this.nivelAdministrativo4){
                    strAddress = '&q=\'' + strTerr4 + ',' + strTerr2 + ',' + strTerr1 + ',' + strTerr0 + '\'';
                }
                if(this.nivelAdministrativo3){
                    strAddress = '&q=\'' + strTerr3 + ',' + strTerr0 + '\'';
                }
                if(this.nivelAdministrativo2){
                    strAddress = '&q=\'' + strTerr2 + ',' + strTerr0 + '\'';
                }
                if(this.nivelAdministrativo1){
                    strAddress = '&q=\'' + strTerr1 + ',' + strTerr0 + '\'';
                }

                console.log('new STRADDRESS', strAddress);
                this.drawingMap(strAddress);
            }
        }).catch(
            (error) => {
                console.log('initializeleaflet [errors : ' + error + ']')
                // this.showMap = false;
            }
        );
    }
}