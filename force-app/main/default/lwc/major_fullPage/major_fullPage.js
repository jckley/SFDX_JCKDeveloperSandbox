import { LightningElement,api,track,wire } from 'lwc';

import retrieveLoggedUserPermissions from '@salesforce/apex/ContactDetailController.retrieveLoggedUserPermissions';
import retrieveInfoFromCitizenId from '@salesforce/apex/CommunitiesController.retrieveInfoFromCitizenId';
import retrieveSite from '@salesforce/apex/CommunitiesController.retrieveSite';

import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

import RESOURCES from '@salesforce/resourceUrl/major';
import { handlePRMCommunityEvent } from 'c/pubsub';

import Yes from '@salesforce/label/c.Yes';
import No from '@salesforce/label/c.No';

//LEAFLET
import leaflet from '@salesforce/resourceUrl/Leafleat';

import aos from '@salesforce/resourceUrl/AOS_JS_Library';
import ContactMobile from '@salesforce/schema/Case.ContactMobile';


export default class Newcom_fullPage extends LightningElement {

    @api recordId;
    @api currentPage;

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
    }


    @wire(retrieveSite)
    wiredSite({ error, data }) {
        if (data) {
            console.log("wiredSite...:", JSON.stringify(data));
            this.community_site = data;

            this.pinURL = RESOURCES + '/img/dark-pin.svg';
            this.iconAddress = RESOURCES + '/img/dark-home.svg';
            this.iconEmail = RESOURCES + '/img/dark-mail.svg';
            this.iconCel = RESOURCES + '/img/dark-cel.svg';
            this.iconFacebook = RESOURCES + '/img/dark-facebook.svg';
            this.iconInstagram = RESOURCES + '/img/dark-instagram.svg';
            this.iconTwitter = RESOURCES + '/img/dark-twitter.svg';
            this.iconLinkedin = RESOURCES + '/img/dark-linkedin.svg';
            this.iconWhatsapp = RESOURCES + '/img/wapp.svg';
            this.iconExpand = RESOURCES + '/img/dark-expand.svg';
            this.iconMobility = RESOURCES + '/img/movilidad.svg';
            this.iconNoData = RESOURCES + '/img/guion.svg';

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
            this.relacionamientoURL = "https://lab.prosumia.la/ct/test/sf/" + this.record.citizen.guid__c; // descomentar para PROD
            if(this.record.citizen.Email !== undefined && this.record.citizen.Email !== null && this.record.citizen.Email !== ''){
                this.emailNoLink = false;
                this.send_email = this.record.citizen.Email;
            } else{
                this.emailNoLink = true;
            }

            this.call_phone = this.record.citizen.HomePhone ? 'tel:' + this.record.citizen.HomePhone : '';
            if(this.record.citizen.MobilePhone !== undefined && this.record.citizen.MobilePhone !== null && this.record.citizen.MobilePhone !== ''){
                this.call_mobile = this.record.citizen.MobilePhone;
                this.cellphoneNoLink = false;

                if(this.record.citizen.Whatsapp__c) {
                    this.write_whatsapp = 'https://api.whatsapp.com/send/?phone=' + this.record.citizen.MobilePhone +'&text&app_absent=0'
                    this.iconWhatsappGray = false;
                } else {
                    this.iconWhatsappGray = true;
                    this.iconWhatsapp = RESOURCES + '/img/wapp-gray.svg';
                }

            } else {
                this.cellphoneNoLink = true;
                this.iconWhatsappGray = true;
                this.iconWhatsapp = RESOURCES + '/img/wapp-gray.svg';
            }
            
            this.photoLegacyUrl = this.record.citizen.PhotoUrl_legacy__c;
            if(this.photoLegacyUrl===undefined || this.photoLegacyUrl===''){
                if(this.record.generalInfo.Gender.toLowerCase() == 'mujer' || this.record.generalInfo.Gender.toLowerCase() == 'female' || this.record.generalInfo.Gender.toLowerCase() == 'f'){
                    this.photoLegacyUrl = RESOURCES + '/img/avatar-w.svg';
                }else{
                    this.photoLegacyUrl = RESOURCES + '/img/avatar-m.svg';
                }
            }

            // URLS / LINKS
            this.hasRelatedCoh = this.record.generalInfo.hasRelatedCoh;

            this.baseURL = window.location.href.substring(0, window.location.href.indexOf("/s")) +'/s/';
            this.relatedLink = this.baseURL + 'global-search/' + encodeURIComponent(this.record.citizen.grouphash_coh__c);

            this.level1Link = this.record.citizen.Level1ID__c ? this.baseURL + 'territorio-administrativo/' + this.record.citizen.Level1ID__c : '';
            this.level2Link = this.record.citizen.Level2ID__c ? this.baseURL + 'territorio-administrativo/' + this.record.citizen.Level2ID__c : '';
            this.level3Link = this.record.citizen.Level3ID__c ? this.baseURL + 'territorio-administrativo/' + this.record.citizen.Level3ID__c : '';
            this.level4Link = this.record.citizen.Level4ID__c ? this.baseURL + 'territorio-administrativo/' + this.record.citizen.Level4ID__c : '';

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
                            scrollWheelZoom: false
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
        window.location.replace(this.relatedLink);
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

}