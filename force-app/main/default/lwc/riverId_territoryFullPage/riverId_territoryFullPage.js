import { LightningElement, api, track, wire } from 'lwc';
import retrieveTerritory from '@salesforce/apex/TerritoryDetailController.retrieveTerritory';
import getTerritoryById from '@salesforce/apex/TerritoryDetailController.getTerritoryById';
import createLog from '@salesforce/apex/TerritoryFullPageController_lt.createLog';

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

const MUJER_COLOR = '#ff3725';
const HOMBRE_COLOR = '#c00000';

const IS_LOG_ENABLED = false;

function customLog(...stringsToLog) {
    if (!IS_LOG_ENABLED || stringsToLog.length === 0) {
        return {forceLog:()=>console.log(...stringsToLog)};
    }
    console.log(...stringsToLog);
    return {forceLog:()=>null};
}

export default class Newcom_territoryFullPage extends LightningElement {
    recordcount = 5;
    
    // @api recordId = "a2L1h000000EO1tEAG"; // Vicente Lopez
    // @api recordId = 'a2L1h000000E5V4EAK'; // William Morris
    // @api community = "Prosumia";
    // @api currentPage = "Community";

    @api recordId;
    @api community;
    @api currentPage;
    @api makeLogs;

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

        if(this.makeLogs){
            createLog({recordId:this.recordId})
            .catch(error=>customLog('Ocurrio un error al intentar crear el log de la busqueda.').forceLog());
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
            console.log('TERRITORY INFO: ', JSON.stringify(this.territoryInfo));

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

            console.log("Actividades Economicas : ", this.territoryInfo.territoryRecord.RiverId_TotEco_Activities__c);
            if(this.territoryInfo.territoryRecord.RiverId_TotEco_Activities__c){
                let actividadesEconomicas = JSON.parse(this.territoryInfo.territoryRecord.RiverId_TotEco_Activities__c);
                let campos_actividadesEconomicas = Object.keys(actividadesEconomicas);

                let sortedArray_actEconomicas;
                try{
                    let arrayToSort = [... campos_actividadesEconomicas];
                    sortedArray_actEconomicas = arrayToSort.sort(
                        (a, b) => {
                            let aFormated = actividadesEconomicas[a];
                            let bFormated = actividadesEconomicas[b];
                            return (bFormated - aFormated)
                        }
                    );
                } catch (e){
                    console.log('error sorting actividades economicas:' , e);
                }
                
                for (var campo of sortedArray_actEconomicas) {
                    this.lstEconomicActivities.push({
                        "image": this.iconEmpleado,
                        "value": actividadesEconomicas[campo],
                        "name": campo,
                        "description": campo});
                }
                this.showEconomicActivities = this.lstEconomicActivities.length>0 ? true : false;
                
            }


            if(this.territoryInfo.riverGeographicdistributions !== undefined && this.territoryInfo.riverGeographicdistributions !== null) {
                if(this.territoryInfo.riverGeographicdistributions.length > 0) {

                    let sortedArray;
                    try{
                        let arrayToSort = [... this.territoryInfo.riverGeographicdistributions];
                        sortedArray = arrayToSort.sort(
                            (a, b) => {
                                let aFormated = parseInt(a.info.value.replace('.', ''));
                                let bFormated = parseInt(b.info.value.replace('.', ''));
                                return (bFormated - aFormated)
                            }
                        );
                    } catch (e){
                        console.log('error sorting child territories:' , e);
                    }
                    


                    for (var gd of sortedArray) {
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
            this.educationLevels.push({
                                        "description": "Primario completo",
                                        "image": this.iconEduPrimaria,
                                        "name": "educacion_primaria",
                                        "value":this.territoryInfo.territoryRecord.RiverId_Total_Edu_Primary__c});
            
            this.educationLevels.push({
                                        "description": "Secundario completo",
                                        "image": this.iconEduSecundaria,
                                        "name": "educacion_secundaria",
                                        "value":this.territoryInfo.territoryRecord.RiverId_Total_Edu_Secondary__c});
            
            this.educationLevels.push({
                                        "description": "Terciario completo / univ. incompleto",
                                        "image": this.iconEduTerciaria,
                                        "name": "educacion_terciaria",
                                        "value":this.territoryInfo.territoryRecord.RiverId_Total_Edu_Tertiary__c});
            
            this.educationLevels.push({
                                        "description": "Universitario completo",
                                        "image": this.iconEduUniversitaria,
                                        "name": "educacion_universitaria",
                                        "value":this.territoryInfo.territoryRecord.RiverId_Total_Edu_University__c});
            
            let strIngresoMuyBajo = this.territoryInfo.territoryRecord.RiverId_TotInc_Very_Low__c;
            let strIngresoBajo = this.territoryInfo.territoryRecord.RiverId_TotInc_Low__c;
            let strIngresoMedio = this.territoryInfo.territoryRecord.RiverId_TotInc_Medium__c;
            let strIngresoAlto = this.territoryInfo.territoryRecord.RiverId_TotInc_High__c;
            let strIngresoMuyAlto = this.territoryInfo.territoryRecord.RiverId_TotInc_Very_High__c;

            //income ranges
            this.incomeranges.push({
                "name": "BAJO",
                "description": "menos de dos SMVM",
                "image": this.iconIngresoBajo,
                "value": (strIngresoMuyBajo + strIngresoBajo)
            });
            
            this.incomeranges.push({
                "name": "MEDIO",
                "description": "entre dos y seis SMVM",
                "image": this.iconIngresoMedio,
                "value": strIngresoMedio
            });
            
            this.incomeranges.push({
                "name": "ALTO",
                "description": "más de seis SMVM",
                "image": this.iconIngresoAlto,
                "value": (strIngresoAlto + strIngresoMuyAlto)
            });

            //occupation types
            this.occupationTypes.push({
                "name": "ASALARIADOS",
                "image": this.iconOcuAsalariado,
                "value": this.territoryInfo.territoryRecord.RiverId_TotOccu_Wage__c
            });
            this.occupationTypes.push({
                "name": "CUENTAPROPISTAS",
                "image": this.iconOcuCuentapropista,
                "value": this.territoryInfo.territoryRecord.RiverId_TotOccu_Self_Employed__c
            });
            this.occupationTypes.push({
                "name": "JUBILADOS",
                "image": this.iconOcuJubilado,
                "value": this.territoryInfo.territoryRecord.RiverId_TotOccu_Retired__c
            });
            this.occupationTypes.push({
                "name": "SIN INGRESOS DECLARADOS",
                "image": this.iconOcuSinIngreso,
                "value": this.territoryInfo.territoryRecord.RiverId_TotOccu_Not_Declared__c
            });
            
            this.error = undefined;
        } else if (error) {
            this.error = error;
            console.log("hubo un error en el wire D:")
        }
        this.isRecordReady = true;
        console.log('total:', this.territoryInfo.riverTotal)
        console.log('men:', this.territoryInfo.riverTotalmen)
        console.log('women:', this.territoryInfo.riverTotalwomen)
        if (this.territoryInfo.riverTotal) {
            let temptw = parseInt(this.territoryInfo.riverTotalwomen.replace('.',''),10);
            let temptm = parseInt(this.territoryInfo.riverTotalmen.replace('.',''),10);
            let tempt = parseInt(this.territoryInfo.riverTotal.replace('.',''),10);
            console.log('typeof: women', typeof temptw, temptw);
            console.log('typeof:men ', typeof temptm, temptm);
            console.log('typeof:total ', typeof tempt, tempt);
            this.totalWomen = temptw;
            this.totalMen = temptm;
            let percentageWomenTemp = temptw / tempt * 100;
            let percentageMenTemp = temptm / tempt * 100;
            console.log('porcentajes?FEMALE: ', percentageWomenTemp);
            console.log('porcentajes?MALE: ', percentageMenTemp);
            this.percentageWomen = parseFloat(percentageWomenTemp ? percentageWomenTemp : 0).toFixed(2);
            this.percentageMen = parseFloat(percentageMenTemp ? percentageMenTemp : 0).toFixed(2);
            this.isRecordReady = true;
            this.callCharts();
        }
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
            
            //this.percentageWomen = parseFloat(this.territoryWrapper.totalWomenPerc ? this.territoryWrapper.totalWomenPerc : 0).toFixed(2);
            //this.percentageMen = parseFloat(this.territoryWrapper.totalMenPerc ? this.territoryWrapper.totalMenPerc : 0).toFixed(2);

            //this.totalWomen = this.territoryWrapper.totalWomen;
            //this.totalMen = this.territoryWrapper.totalMen;

            this.womenCount = [
                this.territoryWrapper.territory.RiverId_Etario_Sub_16_Female__c,
                this.territoryWrapper.territory.RiverId_Etario_Centennials_Female__c,
                this.territoryWrapper.territory.RiverId_Etario_Millennials_Female__c,
                this.territoryWrapper.territory.RiverId_Etario_Generacion_X_Female__c,
                this.territoryWrapper.territory.RiverId_Etario_Baby_Boomers_Female__c,
                this.territoryWrapper.territory.RiverId_Etario_Generacion_Silenciosa_F__c
            ];
            this.menCount = [
                this.territoryWrapper.territory.RiverId_Etario_Sub_16_Male__c,
                this.territoryWrapper.territory.RiverId_Etario_Centennials_Male__c,
                this.territoryWrapper.territory.RiverId_Etario_Millennials_Male__c,
                this.territoryWrapper.territory.RiverId_Etario_Generacion_X_Male__c,
                this.territoryWrapper.territory.RiverId_Etario_Baby_Boomers_Male__c,
                this.territoryWrapper.territory.RiverId_Etario_Generacion_Silenciosa_M__c
            ];

            //this.isWrapperReady = true;

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
                    backgroundColor:HOMBRE_COLOR,
                    stack: 'Stack 0',
                }, {
                    label :'Mujeres',
                    data : [this.womenCount[0], this.womenCount[1], this.womenCount[2], this.womenCount[3], this.womenCount[4], this.womenCount[5]],
                    backgroundColor:MUJER_COLOR,
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
                console.log('this value: ' , value)
                console.log('typeof: ' , typeof value)
                return sum + parseInt(value);
            }, 0);
        }
        console.log('women total: ', this.totalWomen);
        console.log('men total: ', this.totalMen);
        const dataResponse = {
            // These labels appear in the legend and in the tooltips when hovering different arcs
            //el orden de los segmentos esta invertido. Pone a la izquierda el ultimo.
            labels: [
                'Hombres',
                'Mujeres'
            ],
            datasets: [{
                data: [this.totalMen,this.totalWomen],
                backgroundColor: [
                    HOMBRE_COLOR,
                    MUJER_COLOR
                    ],
                borderColor: '#ffffff',
                borderWidth: 4,
                hoverBackgroundColor: [
                    HOMBRE_COLOR,
                    MUJER_COLOR
                ],
                hoverBorderColor: '#ffffff',
                hoverBorderWidth: 0
            }]
        };

        this.chartjsTooltip = this.template.querySelector('.chartjsTooltip');
        // console.log('chartjsTooltip',this.chartjsTooltip);

        console.log('prueba acceso a this afuera.')
        console.log('prueba acceso a this.', this.percentageMen)

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
                console.log('text')
                var bodyLines = tooltip.body.map(getBody);
                var className = bodyLines[0][0].split(":")[0];
                console.log('className', className);
                var innerHtml = '<p class="'+className+'">';
                bodyLines.forEach((body, i) => {
                    if (className == 'Hombres') {
                        innerHtml += this.percentageMen + ' %';
                    }
                    if(className == 'Mujeres') {
                        innerHtml += this.percentageWomen + ' %';
                    }
                    
                    var dataNumber = body[i].split(":");
                    /*var dataValNum = parseInt(dataNumber[1].trim());
                    var dataToPercent = parseFloat(dataValNum / sumOfDataVal(dataResponse) * 100).toFixed(2) + '%';
                    console.log('Previo a mostrar la ayuda2: ' , dataNumber);
                    console.log('Previo a mostrar la ayuda3: ' , dataValNum);
                    console.log('Previo a mostrar la ayuda5: ' , sumOfDataVal(dataResponse));
                    console.log('Previo a mostrar la ayuda4: ' , dataToPercent);
                    */
                    //innerHtml += dataToPercent;
                    innerHtml += '<strong>' + dataNumber[0] + '</strong>';
                });
                
                innerHtml += '</p>';
                this.chartjsTooltip.querySelector('div').innerHTML = innerHtml;

                // sí, toda esta parte debería estar en el .css, pero no me lo toma
                const color = className=='Mujeres'? MUJER_COLOR : HOMBRE_COLOR;
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

                console.log('esto dibujo en mapa:',JSON.stringify(objData))
                
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