import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//import record
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import TRIBU2023 from '@salesforce/schema/Contact.tribu_electoral_2023__c';
const FIELDS = [TRIBU2023];

//apex
import retrieveLoggedUserPermissions from '@salesforce/apex/ContactDetailController.retrieveLoggedUserPermissions';
import retrieveInfoFromCitizenId from '@salesforce/apex/CommunitiesController.retrieveInfoFromCitizenId';
import retrieveSite from '@salesforce/apex/CommunitiesController.retrieveSite';
import createLog from '@salesforce/apex/CommunitiesController.createLog';

//recursos
import RESOURCES from '@salesforce/resourceUrl/Communities';
import prosumerSendSMS from '@salesforce/resourceUrl/prosumerSendSMS';

import PROSUMER from '@salesforce/resourceUrl/prosumerCitizen'

import Yes from '@salesforce/label/c.Yes';
import No from '@salesforce/label/c.No';

//librerias
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import leaflet from '@salesforce/resourceUrl/Leafleat';
import aos from '@salesforce/resourceUrl/AOS_JS_Library';


export default class prosumer_Citizen extends NavigationMixin(LightningElement) {
    @api recordId;
    

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS})
    contact;

    get TRIBU2023() {
        return getFieldValue(this.contact.data, TRIBU2023);
    }

    electoral = PROSUMER + "/electoral.png";
    transporte = PROSUMER + "/transporte.png";
    trabajo = PROSUMER + "/trabajo.png";

    emailIcon = PROSUMER + "/email.png";
    celular = PROSUMER + "/celular.png";


  
    @api currentPage;
    @api makeLogs;

    @track record;
    @track error;
    @track isRecordReady;

    @track community_site;

    @track pinURL;
    @track iconAddress;
    @track iconEmail;
    @track iconCel;
    @track iconFacebook;
    @track iconInstagram;
    @track iconTwitter;
    @track iconLinkedin;
    @track iconWhatsapp;
    @track iconExpand;
    @track iconMobility;
    @track iconNoData;

    @track photoLegacyUrl;
    @track relacionamientoURL;
    @track send_email;
    @track call_phone;
    @track call_mobile;
    @track write_whatsapp;

    @track facebookNoLink = false;
    @track instagramNoLink = false;
    @track twitterNoLink = false;
    @track linkedinNoLink = false;
    @track noParty = true;

    @track email;
    @track emailNoLink = false;
    @track cellphone;
    @track cellphoneNoLink = false;
    @track iconWhatsappGray = false;
    @track mobilities;
    @track tags_array;
    @track personal_data_array;

    @track baseURL;

    relatedLink = null;
    @track hasRelatedCoh;

    @track level1Link;
    @track level2Link;
    @track level3Link;
    @track level4Link;

    @track sticky_class = "sticky_container sticky_container1";
    @track sticky_class2 = "sticky_container fix3";
    @track all_page_class = "all-page";

    @track renderIncomeInfo;
    @track renderMobilityInfo;
    @track renderAttributesInfo;
    @track renderTagInfo;

    @track _permissions;
    get permissions() {
        return this._permissions ? this._permissions : {};
    }
    set permissions(value) {
        this._permissions = value;
    }
    
    formatedItems;

    @track totalIncome

    label = {
        Yes,
        No
    };

    @track noData = "-";

    mapMarkers = [];
    mapOptions = [];

    dblLatitude = null;
    dblLongitude = null;

    @track hasMapView = true;
    streetviewURL = null;
    @track hasStreetView = false;

    // recordId = '0036A000008o4XbQAI';

    @track isSticky = false;

    handleScroll() {
        const element = this.template.querySelector('.my-element');
        const rect = element.getBoundingClientRect();
    
        if (rect.top <= 0 && !this.isSticky) {
          element.classList.add('sticky');
          this.isSticky = true;
        } else if (rect.top > 0 && this.isSticky) {
          element.classList.remove('sticky');
          this.isSticky = false;
        }
    
        const scrollPosition = window.pageYOffset - 1500;
        const maxOpacityPosition = 500; // cambiar aquí para ajustar la posición
        const opacity = Math.min(scrollPosition / maxOpacityPosition, 1);
        element.style.opacity = opacity;
      }

    connectedCallback() {
        window.addEventListener('scroll', this.handleScroll.bind(this));



        console.log("ConnectedCallback");

        retrieveLoggedUserPermissions()
            .then(result => {
                this.permissions = result.permissionsMap;
                this.error = undefined;
                this.doLoadPermissions();
            })
            .catch(error => {
                this.error = error;
                this.permissions = undefined;
            });
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
        console.log(this.currentPage);
        this.sticky_class += " " + this.currentPage;
        this.sticky_class2 += " " + this.currentPage;
        this.all_page_class += " " + this.currentPage;
        if(this.makeLogs){
            createLog({recordId:this.recordId})
            .catch(error=>customLog('Ocurrio un error al intentar crear el log de la busqueda.').forceLog());
        }

       
    }

    doLoadPermissions(){

        console.log('PERMISIONS: ', this.permissions)
    }

    element_is_visible(elem) {
        var base_top = 75;
        var docViewTop = window.scrollY;
        var docViewBottom = docViewTop + window.innerHeight;
        var elemTop = elem.offsetTop + base_top;
        var elemBottom = elemTop + elem.offsetHeight;
        // let ans = ((elemBottom <= docViewBottom) && (elemTop >= docViewTop));
        let ans = ((elemTop + 150  < docViewBottom))
        return ans;
    }


    disconnectedCallback() {
    }

    get citizenInitials () {
        if (!this.record || !this.record.citizen) return null;

        let firstNameInitialToCaps = this.record.citizen.FirstName ? this.record.citizen.FirstName.toUpperCase()[0] : '';
        let lastNameInitialToCaps = this.record.citizen.LastName ? this.record.citizen.LastName.toUpperCase()[0] : '';

        return (firstNameInitialToCaps +  lastNameInitialToCaps);
    }

    parseIntWithThousandsSeparator(integer, separator) {
        return integer.toString().replace(/\B(?=(\d{3})+(?!\d))/g,separator);
    }

    renderedCallback() {
        console.log("renderedCallback");
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

        console.log(this.currentPage);

        this.viveEn();
        this.colorearTribuSpan();
    }


    @wire(retrieveSite)
    wiredSite({ error, data }) {
        if (data) {
            console.log("wiredSite...:", JSON.stringify(data));
            this.community_site = data;

            this.pinURL = PROSUMER + "/icon1.png";

            this.iconAddress = PROSUMER + "/icon2.png";
            
            this.iconEmail = RESOURCES + '/' + this.community_site + '/img/dark-mail.svg';
            this.iconCel = RESOURCES + '/' + this.community_site + '/img/dark-cel.svg';

            this.iconFacebook =  PROSUMER + "/facebook.png";
            this.iconInstagram =  PROSUMER + "/instagram.png";
            this.iconTwitter =  PROSUMER + "/twitter.png";
            this.iconLinkedin = PROSUMER + "/linkedin.png"

            this.iconWhatsapp = RESOURCES + '/' + this.community_site + '/img/wapp.svg';
            this.iconExpand = RESOURCES + '/' + this.community_site + '/img/dark-expand.svg';
            this.iconMobility = RESOURCES + '/' + this.community_site + '/img/movilidad.svg';
            this.iconNoData = RESOURCES + '/' + this.community_site + '/img/guion-naranja.svg';

            let search_bar = document.querySelector(".search-bar-container");
            if (search_bar)
                search_bar.style.display = "";

            let header = document.querySelector("#header-extension");
            if (header)
                header.style.display = "none";
            
            let parent_div = document.querySelector("#parent-div-search-super-m");
            if (parent_div)
                parent_div.style.display = "";

        } else if (error) {
            console.error(error);
            console.error('error.name => ' + error.name );
            console.error('error.message => ' + error.message );
            console.error('error.stack => ' + error.stack );
            this.error = error;
            this.community_site = undefined;
        }
    }


    SiVoto = prosumerSendSMS + '/confirmado.png';
    NoVoto = prosumerSendSMS + '/error.png';

    level0;


    @track carsX = '';
    @track motoX = '';

    @track carShow = true;
    @track motoShow = true;

    electoralArray = [];
    politicaArray = [];
    educationLevel;
    ingresoLevel;
    condicionIngresoArray = [];
    actividadesEconomicasArray = [];

    socialrow1 = false;
    socialrow2 = false;
    socialrow3 = false;
    
    edad;
    sexo;
    generacion;
    fecha_nac;
    nacionalidad;

    @wire(retrieveInfoFromCitizenId, { contactId: '$recordId' })
    wiredContact({ error, data }) {
        console.log("Retrieving Data....");
        this.isRecordReady = false;
        if (data) {
            // console.log(JSON.stringify(data));
            console.log(data);
            this.record = data;
            this.error = undefined;
            console.log("Receiving citizen...");
            this.isRecordReady = true;

            loadStyle(this, leaflet + '/leaflet.css');
            loadScript(this, leaflet + '/leaflet.js').then(() => {
                this.renderMap(0);
            });

            if (data.citizen.Audiencia_Electoral__c){
                this.electoralArray = data.citizen.Audiencia_Electoral__c.split(';').map((elem) => {
                    let capitalizedWords = elem
                        .toLowerCase()
                        .split(' ')
                        .map((word) => {
                            return word.charAt(0).toUpperCase() + word.slice(1);
                        })
                        .join(' ');
                    return capitalizedWords;
                });
            }
            
            if (data.citizen.Audiencia_Politica__c) {
                this.politicaArray = data.citizen.Audiencia_Politica__c.split(';').map((elem) => {
                    let capitalizedWords = elem
                        .toLowerCase()
                        .split(' ')
                        .map((word) => {
                            return word.charAt(0).toUpperCase() + word.slice(1);
                        })
                        .join(' ');
                    return capitalizedWords;
                });
            }
            
            console.log('%c CONDICION DE INGRESO' + JSON.stringify(this.condicionIngresoArray), 'background: #222; color: #bada55')
            
            if (data.citizen.condicion_de_ingreso__c){
                this.condicionIngresoArray = data.citizen.condicion_de_ingreso__c.split(';').map((elem) => {
                    let capitalizedWords = elem
                        .toLowerCase()
                        .split(' ')
                        .map((word) => {
                            return word.charAt(0).toUpperCase() + word.slice(1);
                        })
                        .join(' ');
                    return capitalizedWords;
                });
            }

            console.log('%c CONDICION DE INGRESO ARRAY' + JSON.stringify(data.citizen.condicion_de_ingreso__c), 'background: #222; color: #bada55')
            
            if (data.citizen.actividades_economicas__c) {
                this.actividadesEconomicasArray = data.citizen.actividades_economicas__c.split(';').map((elem) => {
                    let capitalizedWords = elem
                        .toLowerCase()
                        .split(' ')
                        .map((word) => {
                            return word.charAt(0).toUpperCase() + word.slice(1);
                        })
                        .join(' ');
                    return capitalizedWords;
                });
            }


            if (data.citizen.Ingreso__c){
                let capitalizedWords = data.citizen.Ingreso__c
                    .toLowerCase()
                    .charAt(0)
                    .toUpperCase() + data.citizen.Ingreso__c.slice(1).toLowerCase();
                this.ingresoLevel = capitalizedWords;
            }

            if (data.citizen.Education_Level__c) {
                let capitalizedWords = data.citizen.Education_Level__c
                    .toLowerCase()
                    .charAt(0)
                    .toUpperCase() + data.citizen.Education_Level__c.slice(1).toLowerCase();
                this.educationLevel = capitalizedWords;
            }

         

            let carsCount = 0;
            let motoCount = 0;

            this.level0 = data.citizen.Administrative_Level_0__c;

            //console.log('Tiene cantidad autos : '+carsCount);
            
            //console.log('Tiene cantidad motos : '+motoCount);

            data.movilidadInfo.movilidades.forEach(function(item) {
            if (item.clase === 'Car') {
                carsCount++;
            } else if (item.clase === 'Moto') {
                motoCount++;
            }
            });

            //console.log('>after Tiene cantidad autos : '+carsCount);
            
            //console.log('>after Tiene cantidad motos : '+motoCount);

       

            if (carsCount > 1){
                this.carsX = parseInt(carsCount) + ' autos';
            }else{
                this.carsX = parseInt(carsCount) + ' auto';
            }

            if (motoCount > 1){
                this.motoX = parseInt(motoCount) + ' motos';
            }else{
                this.motoX = parseInt(motoCount) + ' moto';
            }


            if (carsCount == 0){
                this.carShow = false;
            }

            if (motoCount == 0){
                this.motoShow = false;
            }

            //console.log('>after>after Tiene cantidad autos : '+carsCount);
            
            //console.log('>after>after Tiene cantidad motos : '+motoCount);

           // this.carsX = carsCount;
           // this.motoX = motoCount;
            

            // MOBILITY
            this.renderMobilityInfo = false;
            this.mobilities = [];
            for (let mobility in this.record.movilidadInfo.movilidades) {
                this.renderMobilityInfo = true;
                if(this.record.movilidadInfo.movilidades[mobility])
                    this.mobilities.push(this.record.movilidadInfo.movilidades[mobility]);
            }
            // console.log('Movilidades: ');
            // console.log(this.mobilities);

            // ELECCIONES
            this.electoral_array1 = []
            this.electoral_array2 = []
            let distrito = (this.record.citizen.Electoral_District__c ? this.record.citizen.Electoral_District__c : " ") + (this.record.citizen.Electoral_District_name__c ? "-" + this.record.citizen.Electoral_District_name__c : "");
            let seccion  = (this.record.citizen.Electoral_Section__c ? this.record.citizen.Electoral_Section__c : " ") + (this.record.citizen.Electoral_Section_name__c ? "-" + this.record.citizen.Electoral_Section_name__c : "");
            let circuito = (this.record.citizen.Electoral_Circuit__c ? this.record.citizen.Electoral_Circuit__c : " ");
            let escuela = (this.record.citizen.Escuela_Electoral__c ? this.record.citizen.Escuela_Electoral__c : " ");
            let mesa = (this.record.citizen.Electoral_Booth__c ? this.record.citizen.Electoral_Booth__c : " ")

            this.electoral_array1.push({"title": "Distrito Electoral", "value": distrito !== undefined && distrito !== null && distrito !== " " ? distrito : "-"});
            this.electoral_array1.push({"title": "Sección"           , "value": seccion !== undefined && seccion !== null && seccion !== " " ? seccion : "-"});
            this.electoral_array1.push({"title": "Circuito"          , "value": circuito !== undefined && circuito !== null && circuito !== " " ? circuito : "-"});
            this.electoral_array2.push({"title": "Establecimiento"   , "value": escuela !== undefined && escuela !== null && escuela !== " " ? escuela : "-"});    
            this.electoral_array2.push({"title": "Mesa"              , "value": mesa !== undefined && mesa !== null && mesa !== " " ? mesa : "-"});
            this.electoral_array2.push({"title": "Orden"             , "value": "Backend"});
            


            this.votos_array = [];
            this.votos_array.push({"text": "2015 PASO"     , "sino": this.record.citizen.voting_P2015__c === 'EMITIDO' ? this.SiVoto : this.NoVoto});
            this.votos_array.push({"text": "2015 General"  , "sino": this.record.citizen.voting_G2015__c === 'EMITIDO' ? this.SiVoto : this.NoVoto});
            this.votos_array.push({"text": "2015 Ballotage", "sino": this.record.citizen.voting_B2015__c === 'EMITIDO' ? this.SiVoto : this.NoVoto});
            this.votos_array.push({"text": "2017 PASO"     , "sino": this.record.citizen.voting_P2017__c === 'EMITIDO' ? this.SiVoto : this.NoVoto});
            this.votos_array.push({"text": "2017 General"  , "sino": this.record.citizen.voting_G2017__c === 'EMITIDO' ? this.SiVoto : this.NoVoto});
            this.votos_array.push({"text": "2019 PASO"     , "sino": this.record.citizen.voting_P2019__c === 'EMITIDO' ? this.SiVoto : this.NoVoto});
            this.votos_array.push({"text": "2019 General"  , "sino": this.record.citizen.voting_G2019__c === 'EMITIDO' ? this.SiVoto : this.NoVoto});
            this.votos_array.push({"text": "2021 PASO"     , "sino": this.record.citizen.voting_P2021__c === 'EMITIDO' ? this.SiVoto : this.NoVoto});
            this.votos_array.push({"text": "2021 General"  , "sino": this.record.citizen.voting_G2021__c === 'EMITIDO' ? this.SiVoto : this.NoVoto});

            console.log('affiliation:', this.record.citizen.party_affiliation__c);
            if(this.record.citizen.party_affiliation__c !== null && this.record.citizen.party_affiliation__c!==undefined && this.record.citizen.party_affiliation__c!==''){
                this.noParty = false;
            } else { this.noParty = true; }
            console.log('noParty:', this.noParty);

            // TAGS
            this.renderTagInfo = false;
            this.tags_array = [];
            for (let tag in this.record.hashTags)
                if(this.record.hashTags[tag].tagsSelected) {
                    this.renderTagInfo = true;

                    for (let i = 0; i < this.record.hashTags[tag].tagsSelected.length; i++) {
                        let capitalizedWords = this.record.hashTags[tag].tagsSelected[i]
                            .toLowerCase()
                            .split(' ')
                            .map((word) => {
                                return word.charAt(0).toUpperCase() + word.slice(1);
                            })
                            .join(' ');
                        this.tags_array.push(capitalizedWords);
                    }

                    // FILTRAR ACA LOS TAGS QUE YA ESTAN SIENDO MOSTRADOS EN PANTALLA
                    console.log("%c FILTRANDO ° STARTS ° >>>>>>>>>>"+this.tags_array, 'background: #222; color: #bada55'); 

                  
                    // - tribu2021 (ojo que TAGS tiene tribu2021, el profile box tiene tribu 2023)

                    const valoresImposibles = [
                        "Cosmopolitas",
                        "Materialistas",
                        "Desencantados",
                        "Tradicionalistas",
                        "Subsistentes",
                        "Progresistas",
                        "Sectores populares",
                        "Conservadores"
                      ];
                      
                      this.tags_array = this.tags_array.filter((tag) => !valoresImposibles.includes(tag));
                      
                      console.log("FILTRANDO - tribu 2021 >>>>>>>>>" + this.tags_array);

                    // - condicion ingreso condicionIngresoArray


                    this.tags_array = this.tags_array.filter(tag => !this.condicionIngresoArray.includes(tag));

                    console.log("FILTRANDO condicion ingreso array >>>>>>>>>>"+this.condicionIngresoArray); 

                    console.log("FILTRANDO ORIGINAL>>>>>>>>>>"+this.tags_array); 



                    // - actividadesEconomicasArray

                    this.tags_array = this.tags_array.filter(tag => !this.actividadesEconomicasArray.includes(tag));

                    console.log("FILTRANDO condicion ingreso array >>>>>>>>>>"+this.actividadesEconomicasArray); 

                    console.log("FILTRANDO ORIGINAL>>>>>>>>>>"+this.tags_array); 


                    // - ingresoLevel
                    // educationLevel

                    // - generacion personal_data_array.generacion 
                    // OJO QUE ESTA EN SINGULAR EN VEZ DE PLUARL por eso vamos a usar this.record.citizen.Audiencia_Generaciones__c

                    let generaciones = this.record.citizen.Audiencia_Generaciones__c;
                    let generacionesCapitalizada = '';
                    
                    if (generaciones) {
                      generacionesCapitalizada = generaciones
                        .toLowerCase()
                        .split(' ')
                        .map((word) => {
                          return word.charAt(0).toUpperCase() + word.slice(1);
                        })
                        .join(' ');
                    }
                    
                    console.log("FILTRANDO GENERACIONES >>>>>>>>>>" + generacionesCapitalizada);
                    
                    this.tags_array = this.tags_array.filter((tag) => tag !== generacionesCapitalizada);
                    
                    console.log("FILTRANDO ORIGINAL>>>>>>>>>>" + this.tags_array);

                    // - electoralArray
                    // - politicaArray
                    this.tags_array = this.tags_array.filter(tag => !this.electoralArray.includes(tag));
                    console.log("FILTRANDO electoral array >>>>>>>>>>"+this.electoralArray); 
                    console.log("FILTRANDO ORIGINAL>>>>>>>>>>"+this.tags_array); 

                    this.tags_array = this.tags_array.filter(tag => !this.politicaArray.includes(tag));
                    console.log("FILTRANDO politica array >>>>>>>>>>"+this.politicaArray); 
                    console.log("FILTRANDO ORIGINAL>>>>>>>>>>"+this.tags_array); 




                }

            //ATTRIBUTES INFO
            this.renderAttributesInfo = false;
            if (this.record.attributes.items !== undefined && this.record.attributes.items !== null && this.record.attributes.items.length > 0){
                this.renderAttributesInfo = true;
                console.log('%c Items' + JSON.stringify(this.record.attributes.items), 'background: #222; color: #bada55')
                this.formatedItems = this.record.attributes.items.map(thisItem => {
                    if(thisItem.label == 'Movilidad' || thisItem.label == 'Mobility'){
                        let valuesArray =  thisItem.value.split(' / ');
                        let nonRepArray = [...new Set(valuesArray)];
                        let nonRepString = nonRepArray.join(' / ');
                        return {
                            label: thisItem.label,
                            value: nonRepString
                        }
                    } else {
                        return thisItem;
                    }
                });
            }
                

            

            //EMPLOYERS INFO
            this.totalIncome = '';
            this.renderIncomeInfo = false;
            if (this.record.incomeInfo.employers !== undefined && this.record.incomeInfo.employers !== null && this.record.incomeInfo.employers.length > 0) {
                this.renderIncomeInfo = true;
                let sum_of_income = 0;
                for (let employer of this.record.incomeInfo.employers) {
                    if (employer.income)
                        sum_of_income += parseInt(employer.income.replace(/\./g, ''));
                    // console.log(`income = ${employer.income}`);
                }
                this.totalIncome = this.parseIntWithThousandsSeparator(sum_of_income, '.');
            }

            // SOCIAL NO LINKS
            if(this.record.citizen.Facebook_Link__c == undefined || this.record.citizen.Facebook_Link__c == null || this.record.citizen.Facebook_Link__c == ''
            || this.record.citizen.Usuario_Facebook__c == undefined || this.record.citizen.Usuario_Facebook__c == null || this.record.citizen.Usuario_Facebook__c == ''){
                this.facebookNoLink = true;
            }

            if(this.record.citizen.Instagram_Link__c == undefined || this.record.citizen.Instagram_Link__c == null || this.record.citizen.Instagram_Link__c == ''
            || this.record.citizen.Usuario_Instagram__c == undefined || this.record.citizen.Usuario_Instagram__c == null || this.record.citizen.Usuario_Instagram__c == ''){
                this.instagramNoLink = true;
            }

            if(this.record.citizen.Twitter_Link__c == undefined || this.record.citizen.Twitter_Link__c == null || this.record.citizen.Twitter_Link__c == ''
            || this.record.citizen.Usuario_Twitter__c == undefined || this.record.citizen.Usuario_Twitter__c == null || this.record.citizen.Usuario_Twitter__c == ''){
                this.twitterNoLink = true;
            }

            if(this.record.citizen.Linkedin_Link__c == undefined || this.record.citizen.Linkedin_Link__c == null || this.record.citizen.Linkedin_Link__c == ''
            || this.record.citizen.Usuario_Linkedin__c == undefined || this.record.citizen.Usuario_Linkedin__c == null || this.record.citizen.Usuario_Linkedin__c == ''){
                this.linkedinNoLink = true;
            }

           


            if (!this.facebookNoLink || !this.twitterNoLink){
            this.socialrow2 = true;
            }      

            if (!this.instagramNoLink || !this.linkedinNoLink){
            this.socialrow3 = true;
            }



           
           

            // SOCIAL
            this.social_array1 = [];
            this.social_array1.push({"icon": this.iconFacebook , "link": (this.record.citizen.Facebook_Link__c ? this.record.citizen.Facebook_Link__c : '') , "usuario": (this.record.citizen.Usuario_Facebook__c ? "/" + this.record.citizen.Usuario_Facebook__c : this.noData), 'social_no_link': this.facebookNoLink});
           
            this.social_array3 = [];
            this.social_array3.push({"icon": this.iconInstagram, "link": (this.record.citizen.Instagram_Link__c ? this.record.citizen.Instagram_Link__c : ''), "usuario": (this.record.citizen.Usuario_Instagram__c ? "@" + this.record.citizen.Usuario_Instagram__c : this.noData), 'social_no_link': this.instagramNoLink});
            
            this.social_array2 = [];
            this.social_array2.push({"icon": this.iconTwitter  , "link": (this.record.citizen.Twitter_Link__c ? this.record.citizen.Twitter_Link__c : '')  , "usuario": (this.record.citizen.Usuario_Twitter__c ? "@" + this.record.citizen.Usuario_Twitter__c : this.noData), 'social_no_link': this.twitterNoLink});
            
            this.social_array4 = [];
            this.social_array4.push({"icon": this.iconLinkedin , "link": (this.record.citizen.Linkedin_Link__c ? this.record.citizen.Linkedin_Link__c : '') , "usuario": (this.record.citizen.Usuario_Linkedin__c ? "/" + this.record.citizen.Usuario_Linkedin__c : this.noData), 'social_no_link': this.linkedinNoLink});

            console.log('social_array',this.social_array);

            this.email = this.record.citizen.Email ? this.record.citizen.Email : this.noData;
            this.cellphone = this.record.citizen.MobilePhone ? this.record.citizen.MobilePhone : this.noData;

            if (this.email != this.noData || this.cellphone != this.noData){
                this.socialrow1 = true;
            }

            // URLS
            // this.relacionamientoURL = "https://lab.prosumia.la/ct/test/sf/ZS6EMLNRjJ"; // para probar en DEV
            // this.relacionamientoURL = "https://lab.prosumia.la/ct/test/sf/ZS6EMLNRjJ?url=dev-prosumia.cs79.force.com/prosumia2/s/contact/"

            // this.relacionamientoURL = "https://lab.prosumia.la/ct/test/sf/" + this.record.citizen.guid__c; // descomentar para PROD

            let temp_url = window.location.href;
            let redirect_url;
            if (temp_url.includes('/r/Contact/')) {
                redirect_url = 'argentina.lightning.force.com/lightning/r/Contact/<id>/view';
            } else {
                // redirect_url = 'argentina.prosumia.app/s/contact/<id>';
                redirect_url = 'arg.prosumer.la/s/contact/<id>';
            }
            
            console.log("NavigationMixin.GenerateUrl");
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    actionName: 'view',
                },
            }).then(url => {
                // url = url.replace(this.recordId, '<id>');
                console.log("Mixin URL BEFORE : ", url);
                let base_redirect_url = url.split(this.recordId)[0];
                console.log("Mixin URL AFTER = ", base_redirect_url);
                base_redirect_url += "<id>";
                // base_redirect_url = base_redirect_url.substring(1);
                base_redirect_url = 'arg.prosumer.la' + base_redirect_url;
                console.log("Mixin URL FINAL = ", base_redirect_url);
                this.relacionamientoURL = `https://lab.prosumia.la/ct/embed/sf/${this.record.citizen.guid__c}?url=${base_redirect_url}`;
            });


            // this.relacionamientoURL = `https://lab.prosumia.la/ct/embed/sf/${this.record.citizen.guid__c}?url=${redirect_url}`;

            
            if(this.record.citizen.Email !== undefined && this.record.citizen.Email !== null && this.record.citizen.Email !== ''){
                this.emailNoLink = false;
                this.send_email = "mailto:"+this.record.citizen.Email;
            } else{
                this.emailNoLink = true;
            }

            this.call_phone = this.record.citizen.HomePhone ? 'tel:' + this.record.citizen.HomePhone : '';
            if(this.record.citizen.MobilePhone !== undefined && this.record.citizen.MobilePhone !== null && this.record.citizen.MobilePhone !== ''){
                this.call_mobile = "tel:"+this.record.citizen.MobilePhone;
                this.cellphoneNoLink = false;

                if(this.record.citizen.Whatsapp__c) {
                    this.write_whatsapp = 'https://api.whatsapp.com/send/?phone=' + this.record.citizen.MobilePhone +'&text&app_absent=0'
                    this.iconWhatsappGray = false;
                } else {
                    this.iconWhatsappGray = true;
                    this.iconWhatsapp = RESOURCES + '/' + this.community_site + '/img/wapp-gray.svg';
                }

            } else {
                this.cellphoneNoLink = true;
                this.iconWhatsappGray = true;
                this.iconWhatsapp = RESOURCES + '/' + this.community_site + '/img/wapp-gray.svg';
            }

            this.photoLegacyUrl = this.record.citizen.PhotoUrl_legacy__c;
            if(this.photoLegacyUrl===undefined || this.photoLegacyUrl===''){
                this.photoLegacyUrl = null;
                /*
                if(this.record.generalInfo.Gender.toLowerCase() == 'mujer' || this.record.generalInfo.Gender.toLowerCase() == 'female' || this.record.generalInfo.Gender.toLowerCase() == 'f'){
                    this.photoLegacyUrl = RESOURCES + '/SALESFORCE/img/avatar-w.svg';
                }else{
                    this.photoLegacyUrl = RESOURCES + '/SALESFORCE/img/avatar-m.svg';
                }
                */
            }

            // URLS / LINKS
            this.hasRelatedCoh = this.record.generalInfo.hasRelatedCoh;

            // this.baseURL = window.location.href.substring(0, window.location.href.indexOf("/s")) +'/s/';
            // this.baseURL2 = window.location.pathname.substring(0, window.location.pathname.indexOf("/s"));
            let urlString = window.location.href;

            console.log("urlString = ", urlString);
            if (urlString.includes("/lightning/")) {
                this.baseURL = urlString.substring(0, urlString.indexOf("/lightning/"));
                this.level1Link = this.record.citizen.Level1ID__c ? this.baseURL + '/lightning/r/Territorio_Administrativo__c/' + this.record.citizen.Level1ID__c + "/view" : '';
                this.level2Link = this.record.citizen.Level2ID__c ? this.baseURL + '/lightning/r/Territorio_Administrativo__c/' + this.record.citizen.Level2ID__c + "/view" : '';
                this.level3Link = this.record.citizen.Level3ID__c ? this.baseURL + '/lightning/r/Territorio_Administrativo__c/' + this.record.citizen.Level3ID__c + "/view" : '';
                this.level4Link = this.record.citizen.Level4ID__c ? this.baseURL + '/lightning/r/Territorio_Administrativo__c/' + this.record.citizen.Level4ID__c + "/view" : '';
                this.relatedLink = this.baseURL + '/lightning/r/global-search/' + encodeURIComponent(this.record.citizen.grouphash_coh__c);



                // {
                //     "componentDef":"forceSearch:searchPageDesktop",
                //     "attributes":{
                //        "term":"mrllanos",
                //        "scopeMap":{
                //           "color":"7F8DE1",
                //           "icon":"https://argentina--DEV.my.salesforce.com/img/icon/t4v35/standard/account_120.png",
                //           "nameField":"Name",
                //           "label":"Account",
                //           "name":"Account",
                //           "cacheable":"Y",
                //           "id":"Account",
                //           "fields":"Name\nLastModifiedDate\nRecordTypeId\nCreatedDate\nId\nLastModifiedById\nSystemModstamp",
                //           "labelPlural":"Accounts",
                //           "entity":"Account"
                //        },
                //        "context":{
                //           "disableSpellCorrection":false,
                //           "disableIntentQuery":false,
                //           "permsAndPrefs":{
                //              "SearchUi.feedbackComponentEnabled":false,
                //              "OrgPreferences.ChatterEnabled":true,
                //              "Search.crossObjectsAutoSuggestEnabled":true,
                //              "OrgPreferences.EinsteinSearchNaturalLanguageEnabled":true,
                //              "SearchUi.searchUIInteractionLoggingEnabled":false,
                //              "MySearch.userCanHaveMySearchBestResult":true,
                //              "SearchResultsLVM.lvmEnabledForTopResults":false
                //           },
                //           "searchDialogSessionId":"682c13e8-4222-183f-a0fc-60c4c18544bd",
                //           "searchSource":"INPUT_DESKTOP"
                //        },
                //        "groupId":"DEFAULT"
                //     },
                //     "state":{
                       
                //     }
                //  }    

                console.log("grouphash_coh__c = ", this.record.citizen.grouphash_coh__c);
                // var searchQuery = encodeURIComponent(this.record.citizen.grouphash_coh__c);
                var searchQuery = this.record.citizen.grouphash_coh__c;

                // var stringToEncode = '{"componentDef":"forceSearch:search","attributes":{"term":"'+ searchQuery + '","scopeMap":{"type":"TOP_RESULTS"},"context":{"disableSpellCorrection":false,"SEARCH_ACTIVITY":{"term":"'+ searchQuery + '"}}}}';
                var stringToEncode = `{
                    "componentDef":"forceSearch:search",
                    "attributes":{
                        "term":"${searchQuery}",
                        "scopeMap":{
                            "nameField":"Name",
                            "fields":"grouphash_coh__c", 
                            "name":"Contact", 
                            "label":"Citizen", 
                            "labelPlural":"Citizens", 
                            "id":"Contact", 
                            "entity":"Contact"
                        },
                        "context":{
                            "disableSpellCorrection":false,
                            "SEARCH_ACTIVITY":{
                                "term":"${searchQuery}"
                            }
                        }
                    }
                }`;

                var encodedString = btoa(stringToEncode);
                this.relatedLink = "/one/one.app?source=alohaHeader#" + encodedString;

                // this.globalSearch = {
                //     type: 'standard__webPage',
                //     attributes: {
                //         url: "/one/one.app?source=alohaHeader#" + encodedString
                //     }
                // };
                // this[NavigationMixin.GenerateUrl](this.globalSearch).then(url => this.relatedLink = url);
                // let url = await this[NavigationMixin.GenerateUrl](this.territoryRecordPage);
                // console.log("1 handleClick url = ", url);

            } else if (urlString.includes("/s/")) {
                this.baseURL = urlString.substring(0, urlString.indexOf("/s/"));
                this.level1Link = this.record.citizen.Level1ID__c ? this.baseURL + '/s/territorio-administrativo/' + this.record.citizen.Level1ID__c + "/view" : '';
                this.level2Link = this.record.citizen.Level2ID__c ? this.baseURL + '/s/territorio-administrativo/' + this.record.citizen.Level2ID__c + "/view" : '';
                this.level3Link = this.record.citizen.Level3ID__c ? this.baseURL + '/s/territorio-administrativo/' + this.record.citizen.Level3ID__c + "/view" : '';
                this.level4Link = this.record.citizen.Level4ID__c ? this.baseURL + '/s/territorio-administrativo/' + this.record.citizen.Level4ID__c + "/view" : '';
                this.relatedLink = this.baseURL + '/s/global-search/' + encodeURIComponent(this.record.citizen.grouphash_coh__c);
            }

            // this.relatedLink = this.baseURL + 'global-search/' + encodeURIComponent(this.record.citizen.grouphash_coh__c);
            console.log("relatedLink = ", this.relatedLink);

            // this.level1Link = this.record.citizen.Level1ID__c ? this.strNewURL + '/s/territorio-administrativo/' + this.record.citizen.Level1ID__c : '';
            // console.log('this.strNewURL:',this.strNewURL);
            console.log('this.level1Link:',this.level1Link);


                   // Set the values directly in the component
                   let labelForFilter;
                   switch (this.record.citizen.Audiencia_Generaciones__c) {
                       case 'SUB 16':
                           labelForFilter = 'SUB 16';
                           break;
                       case 'CENTENNIALS':
                           labelForFilter = 'Centennial';
                           break;
                       case 'MILENNIALS':
                           labelForFilter = 'Millenial';
                           break;
                       case 'GENERACION X':
                           labelForFilter = 'Generación X';
                           break;
                       case 'BABY BOOMERS':
                           labelForFilter = 'Baby Boomer';
                           break;
                       case 'GENERACION SILENCIOSA':
                           labelForFilter = 'Gen. Silenciosa';
                           break;
                       default:
                           labelForFilter = '';
                           break;
                   }

            // PERSONAL_DATA_ARRAY
            this.personal_data_array = {
                "edad": this.record.citizen.Age_f_x__c ? this.record.citizen.Age_f_x__c : "-",
                "fecha_nac": this.record.generalInfo.BirthdateSPFormat ? this.record.generalInfo.BirthdateSPFormat : "-",
                "sexo": this.record.generalInfo.Gender ? this.record.generalInfo.Gender : "-",
                "nacionalidad": this.record.citizen.Nacionalidad__c ? this.record.citizen.Nacionalidad__c : "-",
                "documento": this.record.generalInfo.DNI ? this.record.generalInfo.DNI : "-",
                "cuit": this.record.generalInfo.CUIT ? this.record.generalInfo.CUIT : "-",
                //"guid": this.record.citizen.guid__c ? this.record.citizen.guid__c : false,
                "generacion": labelForFilter ? labelForFilter : "-"
            }
            // console.log('personal_data_array',this.personal_data_array);

            if (this.personal_data_array.edad != "-"){
            this.edad = true;
            }else {this.edad = false};


            if (this.personal_data_array.sexo != "-"){
                this.sexo = true;
                }else{this.sexo = false};
   

           
            if (this.personal_data_array.generacion != "-"){
                this.generacion = true;
                }else{this.generacion = false};

       
            if (this.personal_data_array.nacionalidad != "-"){
                this.nacionalidad = true;
                }else{this.nacionalidad = false};

                if (this.personal_data_array.fecha_nac != "-"){
                    this.fecha_nac = true;
                    }else{this.fecha_nac = false};
           

            this.viveEn();

        } else if (error) {
            console.error(error);
            console.error('error.name => ' + error.name );
            console.error('error.message => ' + error.message );
            console.error('error.stack => ' + error.stack );
            this.error = error;
            this.record = undefined;
            this.isRecordReady = false;
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

    renderMap(scenario) {
        console.log("Rendering Map!!! SCENARIO=", scenario);

        let arrAddress = [];
        let arrAddress2 = [];

        if(this.record !== undefined && this.record !== null && this.record.citizen !== undefined && this.record.citizen !== null) {
            if(this.record.citizen.MailingStreet !== undefined && this.record.citizen.MailingStreet !== null && scenario==0) {
                if(this.record.citizen.MailingNumber__c !== undefined && this.record.citizen.MailingNumber__c !== null) {
                    arrAddress.push(this.record.citizen.MailingStreet + ' ' + this.record.citizen.MailingNumber__c);
                    arrAddress2.push("street="+encodeURIComponent(this.record.citizen.MailingStreet + ' ' + this.record.citizen.MailingNumber__c));
                } else {
                    arrAddress.push(this.record.citizen.MailingStreet );
                    arrAddress2.push("street="+encodeURIComponent(this.record.citizen.MailingStreet));
                }
            }

            if(this.record.citizen.Level4Name__c !== undefined && this.record.citizen.Level4Name__c !== null) {
                arrAddress.push(this.record.citizen.Level4Name__c );
            }

            if(this.record.citizen.Level3Name__c !== undefined && this.record.citizen.Level3Name__c !== null) {
                arrAddress.push(this.record.citizen.Level3Name__c );
                arrAddress2.push("city="+encodeURIComponent(this.record.citizen.Level3Name__c));
            }

            if(this.record.citizen.Level2Name__c !== undefined && this.record.citizen.Level2Name__c !== null) {
                arrAddress.push(this.record.citizen.Level2Name__c );
                arrAddress2.push("county="+encodeURIComponent(this.record.citizen.Level2Name__c));
            }

            if(this.record.citizen.Level1Name__c !== undefined && this.record.citizen.Level1Name__c !== null) {
                arrAddress.push(this.record.citizen.Level1Name__c );
                arrAddress2.push("state="+encodeURIComponent(this.record.citizen.Level1Name__c));
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
            // console.log('loadMapWithAddress [strAddress : ' + strAddress + ']');

            strUrl = URL_GEOLOCATION + '&q=\'' + strAddress + '\'';
            strUrl2 = URL_GEOLOCATION + '&' + strAddress2;
            console.log('loadMapWithAddress [strUrl : ' + strUrl + ']');
            console.log('loadMapWithAddress [strUrl2 : ' + strUrl2 + ']');

            fetch(strUrl2)
            .then((objResponse) => objResponse.json())
            .then((objData) => {
                console.log("objData :", objData);
                if(objData !== undefined && objData !== null && objData.length > 0) {

                    this.hasMapView = true;
                    
                    // console.log('loadMapWithAddress [objData : ' + objData + ']');
                    // console.log('loadMapWithAddress [lat : ' + objData[0].lat + ']');
                    // console.log('loadMapWithAddress [lon : ' + objData[0].lon + ']');
                        
                    this.dblLatitude  = objData[0].lat;
                    this.dblLongitude = objData[0].lon;

                    if (scenario==0) {
                        this.streetviewURL = `https://www.google.com/maps/embed/v1/streetview?key=AIzaSyDSj74xvmqOUCpTnzhRWUegA4XCGcOc5ro&location=${this.dblLatitude},${this.dblLongitude}`;
                        console.log('load Street View : ', this.streetviewURL);
                        this.hasStreetView = true;
                    } else {
                        this.hasStreetView = false;
                    }

                    // console.log('loadMapWithAddress [streetviewURL : ' + this.streetviewURL + ']');

                    let position = [this.dblLatitude, this.dblLongitude];
                    console.log('antes de romper?');
                    console.log('antes de romper? hasMapView' , this.hasMapView);
                    console.log('antes de romper? hasStreetView' , this.hasStreetView);
                    console.log('antes de romper? selector' , this.template.querySelector(".map_container"));

                    if(!this.template.querySelector(".map_container")) return;

                    let mymap = L.map(this.template.querySelector(".map_container"), {
                            scrollWheelZoom: false,
                            dragging: false,
                            tap: false
                    }).setView(position, 18);

                    let CartoDB_Positron = L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
                        // attribution: '&copy; ' + this.community,
                        subdomains: 'abcd',
                        maxZoom: this.intZoom
                    }).addTo(mymap);

                    let locationLayer = new L.FeatureGroup();
                    // let markerTemp = L.marker([this.dblLatitude, this.dblLongitude]).addTo(mymap).bindPopup('');
                    let markerTemp = L.marker([this.dblLatitude, this.dblLongitude]).addTo(mymap);

                    // let iconSettings = {
                    //     mapIconUrl: '<svg id="Grupo_18" data-name="Grupo 18" xmlns="http://www.w3.org/2000/svg"   viewBox="0 0 49.998 68.062"> <defs> <style>.cls-1{fill: #f8595b; opacity: 0.26;}.cls-2{fill: #333; opacity: 0.6;}.cls-2, .cls-3, .cls-4{fill-rule: evenodd;}.cls-3{fill: #f3bb49;}.cls-4{fill: #fff;}</style> </defs> <circle id="Elipse_3" data-name="Elipse 3" class="cls-1" cx="24.999" cy="60.047" r="7.999"/> <path id="Elipse_3_copia" data-name="Elipse 3 copia" class="cls-2" d="M1004.55,713.517a3.722,3.722,0,1,1-3.71,3.721A3.717,3.717,0,0,1,1004.55,713.517Z" transform="translate(-979.562 -657.188)"/> <path id="Forma_13" data-name="Forma 13" class="cls-3" d="M1004.55,657.2a24.971,24.971,0,0,0-11.518,47.14c1.816,1.131,9.418,6.177,11.168,12.327,0.23,0.808.49,0.759,0.73-.071,1.78-6.121,9.34-11.129,11.15-12.256A24.974,24.974,0,0,0,1004.55,657.2Z" transform="translate(-979.562 -657.188)"/> <path id="ico-home" class="cls-4" d="M1014.76,681.224l-3.87-3.468-0.55-.5v-3.534a0.675,0.675,0,1,0-1.35,0v2.331l-2.76-2.479a1.823,1.823,0,0,0-2.43,0l-8.552,7.647a0.692,0.692,0,0,0-.061.964,0.664,0.664,0,0,0,.948.062l1.943-1.737v8.169a1.835,1.835,0,0,0,1.818,1.849h1.854a1.589,1.589,0,0,0,1.57-1.6V684.8a0.477,0.477,0,0,1,.47-0.483h2.34a0.486,0.486,0,0,1,.48.485v4.131a1.582,1.582,0,0,0,1.57,1.6h1.94a1.846,1.846,0,0,0,1.83-1.857v-8.148l1.92,1.723a0.667,0.667,0,0,0,.95-0.061A0.7,0.7,0,0,0,1014.76,681.224Z" transform="translate(-979.562 -657.188)"/></svg>',
                    //     mapIconColor: '#cc756b',
                    //     mapIconColorInnerCircle: '#fff',
                    //     pinInnerCircleRadius:48
                    // };
                    
                    // icon normal state
                    // let divIcon = L.divIcon({
                    //     className: "leaflet-data-marker",
                    //     html: L.Util.template(iconSettings.mapIconUrl, iconSettings), //.replace('#','%23'),
                    //     iconAnchor  : [13, 55],
                    //     iconSize    : [50],
                    //     popupAnchor : [0, -100]
                    // });

                    
                } else {
                    if (scenario==0)
                        this.renderMap(1);
                    else
                        this.hasMapView = false;
                }
            });
        }

        // this.template.dispatchEvent(new Event("DOMContentLoaded"));
        this.template.dispatchEvent(new Event("ready"));
        window.dispatchEvent(new Event('ready'));
        window.dispatchEvent(new Event('DOMContentLoaded'));
    }

    goToRelated() {
        // window.location.replace(this.relatedLink);
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.relatedLink
            }
        } //,
        // true // Replaces the current page in your browser history with the URL
      );
    }

    goToLevel1() {
        window.location.replace(this.level1Link);
    }

    goToLevel2() {
        window.location.replace(this.level2Link);
    }

    goToLevel3() {
        window.location.replace(this.level3Link);
    }

    goToLevel4() {
        window.location.replace(this.level4Link);
    }


    ViveEnEscrito = false;

    viveEn(){
        console.log('%c viveEn() inicializado', 'background: #222; color: #bada55');

        const address = this.template.querySelector('.address');
        const primerSpan = this.template.querySelector('.address .value:first-of-type');

        /*console.log('%c address > '+address, 'background: #222; color: #bada55');

        console.log('%c primerSpan > '+primerSpan, 'background: #222; color: #bada55');*/

        if (primerSpan && !this.ViveEnEscrito) {
        primerSpan.innerHTML = 'Vive en ' + primerSpan.innerHTML;
        this.ViveEnEscrito = true;

        console.log('%c "Vive en" fue colocado en pantalla satisfactoriamente', 'color: #222; background: #bada55');
        }


    }

    colorearTribuSpan() {
        const tribus = this.template.querySelectorAll('.tribu');
        console.log('colorearTribuSpan iniciado correctamente');
      
        tribus.forEach(tribu => {
          switch (tribu.innerHTML) {
            case 'Amarillos':
              tribu.classList.add('amarillos');
              break;
            case 'Azules':
              tribu.classList.add('azules');
              break;
            case 'Celestes':
              tribu.classList.add('celestes');
              break;
            case 'Naranjas':
              tribu.classList.add('naranjas');
              break;
            case 'Rojos':
              tribu.classList.add('rojos');
              break;
            case 'Verdes':
              tribu.classList.add('verdes');
              break;
            case 'Violetas':
              tribu.classList.add('violetas');
              break;
            default:
              break;
          }
        });
      }

    endLayout(){
        const clickLayout = this.template.querySelector('.clickLayout');
        clickLayout.style.display = 'none';
    }
}