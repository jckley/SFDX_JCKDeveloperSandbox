import { LightningElement,api,track,wire } from 'lwc';

import retrieveLoggedUserPermissions from '@salesforce/apex/ContactDetailController.retrieveLoggedUserPermissions';
import retrieveInfoFromCitizenId from '@salesforce/apex/CommunitiesController.retrieveInfoFromCitizenId';
import retrieveSite from '@salesforce/apex/CommunitiesController.retrieveSite';
import createLog from '@salesforce/apex/CommunitiesController.createLog';

import retrieveInfoPollsFromCitizenId from '@salesforce/apex/CommunitiesRiverController.retrieveInfoPollsFromCitizenId';


import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

import RESOURCES from '@salesforce/resourceUrl/Communities';
import RESOURCES2 from '@salesforce/resourceUrl/RiverIdResourses';
import { handlePRMCommunityEvent } from 'c/pubsub';

import Yes from '@salesforce/label/c.Yes';
import No from '@salesforce/label/c.No';

// LEAFLET
import leaflet from '@salesforce/resourceUrl/Leafleat';
// ChartJS
import chartjs from '@salesforce/resourceUrl/ChartJS';

import aos from '@salesforce/resourceUrl/AOS_JS_Library';
import ContactMobile from '@salesforce/schema/Case.ContactMobile';

import { NavigationMixin } from 'lightning/navigation';

const IS_LOG_ENABLED = false;

function customLog(...stringsToLog) {
    if (!IS_LOG_ENABLED || stringsToLog.length === 0) {
        return {forceLog:()=>console.log(...stringsToLog)};
    }
    console.log(...stringsToLog);
    return {forceLog:()=>null};
}

// export default class Newcom_fullPage extends LightningElement {
export default class Newcom_fullPage extends NavigationMixin(LightningElement) {
    @api recordId;
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


    @track sticky_class = "sticky_container";
    @track all_page_class = "all-page";

    @track renderIncomeInfo;
    @track renderMobilityInfo;
    @track renderAttributesInfo;
    @track renderTagInfo;

    @track totalIncome;

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

    // flag for polls related data
    @track hasPollsData = true;

    isChartJsInitialized = false;

    // Parameters for Satisfaction (doughnat) chart
    @track satisfactionLevel = 0.0;
    
    // Parameters for Satisfaction (radar) chart
    susRespuestas = [];

    // Parameters for Evolution (stacked bars) Chart
    futbolCount = [];
    estadioCount = [];
    abonosCount = [];
    instalacionesCount = [];
    beneficiosCount = [];
    labels = [];


    get socioId () {
        if (!this.record?.citizen?.RiverIds__r ||
            this.record.citizen.RiverIds__r.length == 0){
            return
        }

        return this.record.citizen.RiverIds__r[0].nro_socio__c;
        
    }

    // recordId = '0036A000008o4XbQAI';

    connectedCallback() {
        console.log("ConnectedCallback");
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
        // this.loadChartJS();

        console.log(this.currentPage);
    }


    @wire(retrieveInfoPollsFromCitizenId, { contactId: '$recordId' })
    wiredPollsData({ error, data }) {
        console.log("Retrieving Data retrieveInfoPollsFromCitizenId ....");
        this.isRecordReady = false;
        if (data) {
            console.log("data = ", data);
            if (data.length > 0) {
                this.hasPollsData = true;
                this.processPollsData(data);
            }
        } else  {
            if (error)
                console.error(error);
        }
    }



    @wire(retrieveSite)
    wiredSite({ error, data }) {
        if (data) {
            console.log("wiredSite...:", JSON.stringify(data));
            this.community_site = data;

            this.pinURL = RESOURCES + '/' + this.community_site + '/img/dark-pin.svg';
            this.iconAddress = RESOURCES + '/' + this.community_site + '/img/dark-home.svg';
            this.iconEmail = RESOURCES + '/' + this.community_site + '/img/dark-mail.svg';
            this.iconCel = RESOURCES + '/' + this.community_site + '/img/dark-cel.svg';
            this.iconFacebook = RESOURCES + '/' + this.community_site + '/img/dark-facebook.svg';
            this.iconInstagram = RESOURCES + '/' + this.community_site + '/img/dark-instagram.svg';
            this.iconTwitter = RESOURCES + '/' + this.community_site + '/img/dark-twitter.svg';
            this.iconLinkedin = RESOURCES + '/' + this.community_site + '/img/dark-linkedin.svg';
            this.iconWhatsapp = RESOURCES + '/' + this.community_site + '/img/wapp.svg';
            this.iconExpand = RESOURCES + '/' + this.community_site + '/img/dark-expand.svg';
            this.iconMobility = RESOURCES + '/' + this.community_site + '/img/movilidad.svg';
            this.iconNoData = RESOURCES2 + '/guion.svg';
            //@salesforce/resourceUrl/Communities
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
            // console.error('error.name => ' + error.name );
            // console.error('error.message => ' + error.message );
            // console.error('error.stack => ' + error.stack );
            this.error = error;
            this.community_site = undefined;
        }
    }

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

            this.loadChartJS();

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
            this.electoral_array = []
            let distrito = (this.record.citizen.Electoral_District__c ? this.record.citizen.Electoral_District__c : " ") + (this.record.citizen.Electoral_District_name__c ? "-" + this.record.citizen.Electoral_District_name__c : "");
            let seccion  = (this.record.citizen.Electoral_Section__c ? this.record.citizen.Electoral_Section__c : " ") + (this.record.citizen.Electoral_Section_name__c ? "-" + this.record.citizen.Electoral_Section_name__c : "");
            let circuito = (this.record.citizen.Electoral_Circuit__c ? this.record.citizen.Electoral_Circuit__c : " ");
            let escuela = (this.record.citizen.Escuela_Electoral__c ? this.record.citizen.Escuela_Electoral__c : " ");
            let mesa = (this.record.citizen.Electoral_Booth__c ? this.record.citizen.Electoral_Booth__c : " ")

            this.electoral_array.push({"title": "Distrito electoral:", "value": distrito});
            this.electoral_array.push({"title": "Sección:"           , "value": seccion});
            this.electoral_array.push({"title": "Circuito:"          , "value": circuito});
            this.electoral_array.push({"title": "Escuela:"           , "value": escuela});
            this.electoral_array.push({"title": "Mesa:"              , "value": mesa});

            this.votos_array = [];
            this.votos_array.push({"text": "Voto 2015 Paso"     , "sino": this.record.citizen.voting_P2015__c === 'EMITIDO' ? this.label.Yes : this.label.No});
            this.votos_array.push({"text": "Voto 2015 General"  , "sino": this.record.citizen.voting_G2015__c === 'EMITIDO' ? this.label.Yes : this.label.No});
            this.votos_array.push({"text": "Voto 2015 Ballotage", "sino": this.record.citizen.voting_B2015__c === 'EMITIDO' ? this.label.Yes : this.label.No});
            this.votos_array.push({"text": "Voto 2017 Paso"     , "sino": this.record.citizen.voting_P2017__c === 'EMITIDO' ? this.label.Yes : this.label.No});
            this.votos_array.push({"text": "Voto 2017 General"  , "sino": this.record.citizen.voting_G2017__c === 'EMITIDO' ? this.label.Yes : this.label.No});
            this.votos_array.push({"text": "Voto 2019 Paso"     , "sino": this.record.citizen.voting_P2019__c === 'EMITIDO' ? this.label.Yes : this.label.No});
            this.votos_array.push({"text": "Voto 2019 General"  , "sino": this.record.citizen.voting_G2019__c === 'EMITIDO' ? this.label.Yes : this.label.No});
            this.votos_array.push({"text": "Voto 2021 Paso"     , "sino": this.record.citizen.voting_P2021__c === 'EMITIDO' ? this.label.Yes : this.label.No});

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
                    for (let i = 0 ; i < this.record.hashTags[tag].tagsSelected.length ; i++)
                        this.tags_array.push(this.record.hashTags[tag].tagsSelected[i].toUpperCase());
                }

            //ATTRIBUTES INFO
            this.renderAttributesInfo = false;
            if (this.record.attributes.items !== undefined && this.record.attributes.items !== null && this.record.attributes.items.length > 0)
                this.renderAttributesInfo = true;

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

            // SOCIAL
            this.social_array = [];
            this.social_array.push({"icon": this.iconFacebook , "link": (this.record.citizen.Facebook_Link__c ? this.record.citizen.Facebook_Link__c : '') , "usuario": (this.record.citizen.Usuario_Facebook__c ? "/" + this.record.citizen.Usuario_Facebook__c : this.noData), 'social_no_link': this.facebookNoLink});
            this.social_array.push({"icon": this.iconInstagram, "link": (this.record.citizen.Instagram_Link__c ? this.record.citizen.Instagram_Link__c : ''), "usuario": (this.record.citizen.Usuario_Instagram__c ? "@" + this.record.citizen.Usuario_Instagram__c : this.noData), 'social_no_link': this.instagramNoLink});
            this.social_array.push({"icon": this.iconTwitter  , "link": (this.record.citizen.Twitter_Link__c ? this.record.citizen.Twitter_Link__c : '')  , "usuario": (this.record.citizen.Usuario_Twitter__c ? "@" + this.record.citizen.Usuario_Twitter__c : this.noData), 'social_no_link': this.twitterNoLink});
            this.social_array.push({"icon": this.iconLinkedin , "link": (this.record.citizen.Linkedin_Link__c ? this.record.citizen.Linkedin_Link__c : '') , "usuario": (this.record.citizen.Usuario_Linkedin__c ? "/" + this.record.citizen.Usuario_Linkedin__c : this.noData), 'social_no_link': this.linkedinNoLink});

            console.log('social_array',this.social_array);

            this.email = this.record.citizen.Email ? this.record.citizen.Email : this.noData;
            this.cellphone = this.record.citizen.MobilePhone ? this.record.citizen.MobilePhone : this.noData;

            // URLS
            // this.relacionamientoURL = "https://lab.prosumia.la/ct/test/sf/ZS6EMLNRjJ"; // para probar en DEV

            this.relacionamientoURL = "https://lab.prosumia.la/ct/embed/sf/" + this.record.citizen.guid__c + "?url=comunidad.riverid.app/s/contact/<id>"; // descomentar para PROD
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
                /*if(this.record.generalInfo.Gender.toLowerCase() == 'mujer' || this.record.generalInfo.Gender.toLowerCase() == 'female' || this.record.generalInfo.Gender.toLowerCase() == 'f'){
                    this.photoLegacyUrl = RESOURCES + '/SALESFORCE/img/avatar-w.svg';
                }else{
                    this.photoLegacyUrl = RESOURCES + '/SALESFORCE/img/avatar-m.svg';
                }*/
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

            // PERSONAL_DATA_ARRAY
            this.personal_data_array = {
                "edad": this.record.citizen.Age_f_x__c ? this.record.citizen.Age_f_x__c : this.noData,
                "fecha_nac": this.record.generalInfo.BirthdateSPFormat ? this.record.generalInfo.BirthdateSPFormat : this.noData,
                "sexo": this.record.generalInfo.Gender ? this.record.generalInfo.Gender : this.noData,
                "nacionalidad": this.record.citizen.Nacionalidad__c ? this.record.citizen.Nacionalidad__c : this.noData,
                "documento": this.record.generalInfo.DNI ? this.record.generalInfo.DNI : this.noData,
                "cuit": this.record.generalInfo.CUIT ? this.record.generalInfo.CUIT : this.noData,
                "guid": this.record.citizen.guid__c ? this.record.citizen.guid__c : this.noData
            }
            // console.log('personal_data_array',this.personal_data_array);

            this.callCharts();

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


    // ***********************************************************
    // Typeform Survey Charts
    // ***********************************************************

    processPollsData(data) {
        console.log("Process Polls Data...");

        let total_abonos = 0.0;
        let total_beneficios = 0.0;
        let total_estadio = 0.0;
        let total_futbol = 0.0;
        let total_instalaciones = 0.0;

        let counter = 0.0;

        const months = ["ENE","FEB","MAR","ABR","MAY","JUN","JUL","AGO","SEP","OCT","NOV","DIC"];

        let time_series = {};


        let dt = new Date();
        let year = dt.getFullYear();
        let month = dt.getMonth();
        let zeroes_month = `00${month}`
        let key = `${year}`+zeroes_month.substring(zeroes_month.length - 2);
        time_series[key] = [0.0, 0.0, 0.0, 0.0, 0.0]

        data.forEach(poll => {
            total_futbol += poll.Futbol__c;
            total_estadio += poll.Estadio__c;
            total_abonos += poll.Abonos__c;
            total_instalaciones += poll.Instalaciones__c;
            total_beneficios += poll.Beneficios__c;

            dt = new Date(poll.Fecha_Respuesta__c);
            year = dt.getFullYear();
            month = dt.getMonth();
            zeroes_month = `00${month}`
            key = `${year}`+zeroes_month.substring(zeroes_month.length - 2);

            if (key in time_series) {
                console.log("Key already exists");
                time_series[key] = [time_series[key][0] + poll.Futbol__c, time_series[key][1] + poll.Estadio__c, time_series[key][2] + poll.Abonos__c, time_series[key][3] + poll.Instalaciones__c, time_series[key][4] + poll.Beneficios__c, time_series[key][5] + 1]
            } else {
                console.log("key does not exist");
                time_series[key] = [poll.Futbol__c, poll.Estadio__c, poll.Abonos__c, poll.Instalaciones__c, poll.Beneficios__c, 1];
            }

            console.log(dt, months[month], year);

            counter += 1;
        });

        let promedio_futbol = total_futbol / counter;
        let promedio_estadio = total_estadio / counter;
        let promedio_abonos = total_abonos / counter;
        let promedio_instalaciones = total_instalaciones / counter;
        let promedio_beneficios = total_beneficios / counter;

        this.susRespuestas = [promedio_futbol, promedio_estadio, promedio_abonos, promedio_instalaciones, promedio_beneficios];

        let suma_promedios = promedio_futbol + promedio_estadio + promedio_abonos + promedio_instalaciones + promedio_beneficios;
        this.satisfactionLevel = (Math.round(suma_promedios * 10.0 / 5.0) / 10.0).toFixed(1);
        console.log(this.satisfactionLevel);


        console.log(time_series);

        // get most recent period
        let most_recent_period = '';
        Object.entries(time_series).forEach(([key, value]) => {
            if (key > most_recent_period) {
                most_recent_period = key;
            }
        });
        console.log(`most_recent_period = ${most_recent_period}`)
        

        let most_recent_month = parseInt(most_recent_period.substring(most_recent_period.length - 2));
        let most_recent_year = parseInt(most_recent_period.substring(0, 4));
        console.log (`${most_recent_month} ${most_recent_year}`)


        year = most_recent_year;
        month = most_recent_month;
        for (let i = 0 ; i < 10 ; i++) {

            let zeroes_month = `00${month}`
            let key = `${year}`+zeroes_month.substring(zeroes_month.length - 2);
            console.log(key);

            if (key in time_series) {
                this.futbolCount.unshift(time_series[key][0] / time_series[key][5]);
                this.estadioCount.unshift(time_series[key][1] / time_series[key][5]);
                this.abonosCount.unshift(time_series[key][2] / time_series[key][5]);
                this.instalacionesCount.unshift(time_series[key][3] / time_series[key][5]);
                this.beneficiosCount.unshift(time_series[key][4] / time_series[key][5]);
            } else {
                this.futbolCount.unshift(0.0);
                this.estadioCount.unshift(0.0);
                this.abonosCount.unshift(0.0);
                this.instalacionesCount.unshift(0.0);
                this.beneficiosCount.unshift(0.0);
            }

            this.labels.unshift(months[month]);

            month = month - 1;
            if (month < 0) {
                month = 11;
                year = year -1;
            }
        }


    }

    callCharts(){
        console.log("callCharts isRecordReady = ", this.isRecordReady);
        try{
            if(this.isRecordReady){
                this.evolutionChart();
                this.satisfactionChart();
                this.radarChart()
            }
        }catch(error){
            console.log(error);
        }
    }

    loadChartJS(){
        console.log("loadChartJS isChartJsInitialized = ", this.isChartJsInitialized);

        if (this.isChartJsInitialized) {
            return;
        }

        // LOAD CHART JS
        loadScript(this, chartjs + '/Chart.bundle.min.js')
            .then(() => {
                this.isChartJsInitialized = true;
                console.log('Dibujo charts');
                this.evolutionChart();
                this.satisfactionChart();
                this.radarChart();
            })
            .catch(error => console.log(error));
    }

    // chart de distribución etaria
    evolutionChart(){
        let COLOR_BENEFICIOS = '#d42e59';
        let COLOR_INSTALACIONES = '#ed5929';
        let COLOR_ABONOS = '#4a516e';
        let COLOR_ESTADIO = '#47ace2';
        let COLOR_FUTBOL = '#55bd55';

        console.log("evolutionChart");
        console.log(this.labels);
        console.log(this.abonosCount);

        const dataResponse = {
            // These labels appear in the legend and in the tooltips when hovering different arcs
            labels: this.labels,
            datasets: [
                {
                    label :'FÚTBOL',
                    data : this.futbolCount,
                    backgroundColor:COLOR_FUTBOL,
                    borderColor:COLOR_FUTBOL,
                    stack: 'Stack 0',
                },
                {
                    label :'ESTADIO',
                    data : this.estadioCount,
                    backgroundColor:COLOR_ESTADIO,
                    borderColor:COLOR_ESTADIO,
                    stack: 'Stack 0',
                },
                {
                    label :'ABONOS',
                    data : this.abonosCount,
                    backgroundColor:COLOR_ABONOS,
                    borderColor:COLOR_ABONOS,
                    stack: 'Stack 0',
                },                
                {
                    label :'INSTALACIONES',
                    data : this.instalacionesCount,
                    backgroundColor:COLOR_BENEFICIOS,
                    borderColor:COLOR_BENEFICIOS,
                    stack: 'Stack 0',
                },
                {
                    label :'BENEFICIOS',
                    data : this.beneficiosCount,
                    backgroundColor:COLOR_INSTALACIONES,
                    borderColor:COLOR_INSTALACIONES,
                    stack: 'Stack 0',
                },
            ]
    
        };
    
        const config = {
            type: 'bar',
            data: dataResponse,
            options: {
                legend: {
                    position: 'bottom',
                    labels: {
                        boxWidth: 10,
                        fontColor: "#aaaaaa",
                        fontSize: 10,
                    },
                },
                y: {
                    beginAtZero: true
                }
                ,plugins: {
                    title: {
                        display: false
                    },
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
                            autoSkip: false,
                            suggestedMin: 0,
                            suggestedMax: 25,
                        },
                        gridLines: {
                            drawBorder: false,
                        }
                    }],
                    xAxes: [{
                        ticks: {
                            autoSkip: false,
                        },
                        gridLines: {
                            display: false,
                        },
                    }]
                }
            }
        }

        let evoChart = this.template.querySelector('canvas.evolutionChart');
        console.log("evoChart = ", evoChart);
        let ctx = evoChart.getContext('2d');
        console.log("ctx = ", ctx);

        // let ctx = this.template.querySelector('canvas.evolutionChart').getContext('2d');
        this.chart_evolution = new Chart(ctx, config);
    }

    // chart de habitantes
    satisfactionChart(){
        let COLOR_SATISFACTION = '#ff0000';
        let COLOR_INSATISFACTION = '#f2f2f2';

        // this.satisfactionLevel = 3.8;
        this.insatisfactionLevel = 5.0 - this.satisfactionLevel;

        const dataResponse = {
            labels: [
                'Nivel de Satisfaccion',
                ''
            ],
            datasets: [{
                data: [this.satisfactionLevel, this.insatisfactionLevel],
                backgroundColor: [
                    COLOR_SATISFACTION,
                    COLOR_INSATISFACTION
                    ],
                borderColor: '#ffffff',
                borderWidth: 0,
                hoverBackgroundColor: [
                    COLOR_SATISFACTION,
                    COLOR_INSATISFACTION
                ],
                hoverBorderColor: '#ffffff',
                hoverBorderWidth: 0
            }]
        };


        const config = {
            type: 'doughnut',
            data: dataResponse,
            options: {
                legend: {
                    display: false
                },
                tooltips: {
                    enabled: false,
                },
                hover: {mode: null,},
                cutoutPercentage: 85,
                circumference: 2 * Math.PI,
                maintainAspectRatio: false,
                animation: {
                    animateRotate: false,
                    animateScale: true
                },
            }
        }
    
        let ctx = this.template.querySelector('canvas.satisfactionChart').getContext('2d');
        this.chart_satisfaction = new Chart(ctx, config);

    }

    // chart de habitantes
    radarChart(){
        let COLOR_SUS_RESPUESTAS = '#ff0000';
        let COLOR_SUS_RESPUESTAS_BACKGROUND = '#ff000040';
        let COLOR_RESPUESTAS_PROMEDIO = '#567b8b';
        let COLOR_RESPUESTAS_PROMEDIO_BACKGROUND = '#567b8b40';

        const labels = ["FÚTBOL", "ESTADIO", "ABONOS", "INSTALACIONES", "BENEFICIOS"];
        const data = {
            labels: labels,
            datasets: [
                {
                    label: 'Sus Respuestas',
                    data: this.susRespuestas,
                    borderColor: COLOR_SUS_RESPUESTAS,
                    backgroundColor: COLOR_SUS_RESPUESTAS_BACKGROUND,
                },
                {
                    label: 'Respuestas Promedio',
                    data: [4, 4, 3, 1, 4],
                    borderColor: COLOR_RESPUESTAS_PROMEDIO,
                    backgroundColor: COLOR_RESPUESTAS_PROMEDIO_BACKGROUND,
                }
            ]
        };

        const config = {
            type: 'radar',
            data: data,
            options: {
                responsive: true,

                legend: {
                    labels: {
                        boxWidth: 4,
                        // pointStyle: 'circle',
                        usePointStyle: true,
                    },
                },
                scale: {
                    ticks: {
                        suggestedMin: 0,
                        suggestedMax: 5,
                        stepSize: 1,
                    },
                    pointLabels: {
                        fontColor: '#aaaaaa',
                    },
                },
            },

            plugins: [
                {
                    beforeInit: function(chart, options) {
                        chart.legend.afterFit = function() {
                            this.height = this.height + 20;
                        };
                    }
                },
            ],

        };
   
        let ctx = this.template.querySelector('canvas.radarChart').getContext('2d');
        this.chart_satisfaction = new Chart(ctx, config);

    }



}