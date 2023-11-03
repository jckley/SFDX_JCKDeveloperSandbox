import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import retrieveActivistaFromId from '@salesforce/apex/empatiaController.retrieveActivistaFromId';
import retrieveNotasFromActivistaFromId from '@salesforce/apex/empatiaController.retrieveNotasFromActivistaFromId';
import insertNota from '@salesforce/apex/empatiaController.insertNota';
import createLog from '@salesforce/apex/empatiaController.createLog';

import { standardIcons } from 'c/utils';
import { renderMap } from './mapUtils';

//LIBRERIAS AUXILIARES
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import leaflet from '@salesforce/resourceUrl/Leafleat';
import aos from '@salesforce/resourceUrl/AOS_JS_Library';

import faviconEmpatia from '@salesforce/resourceUrl/faviconEmpatia';

const IS_LOG_ENABLED = false;

function customLog(...stringsToLog) {
    if (!IS_LOG_ENABLED || stringsToLog.length === 0) {
        return {forceLog:()=>console.log(...stringsToLog)};
    }
    console.log(...stringsToLog);
    return {forceLog:()=>null};
}

export default class Empatia_fullPage extends NavigationMixin(LightningElement) {
    @api recordId;
    @api currentPage;
    @api makeLogs;

    @track social_array = [];

    isRecordReady = false;
    areNotasReady = false;

    get isAllDataReady() {
        return this.areNotasReady && this.isRecordReady
    }

    record;
    notasArray;
    community_site;

    favicon = faviconEmpatia;
    iconsSet = standardIcons;
    iconNoData = standardIcons.iconNoData;

    noDataLong = '–';

    sticky_class = "sticky_container";
    all_page_class = "all-page";

    get permissions() {
        return {
            Contact_View_Common_Data: true,
            Contact_View_Location: true,
            Contact_View_Contact_Info: true,
            Contact_View_Relationship: true,
            Contact_View_Social_Info: true
        };
    }

    leafletInitNeeded = true;

    @track hasMapView = true;
    streetviewURL = null;
    @track hasStreetView = false;

    renderMap = renderMap.bind(this)

    connectedCallback() {
        console.log("ConnectedCallback");

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

    renderedCallback() {
        console.log("renderedCallback");
        loadStyle(this, aos + '/aos.css').then(() => {
            loadScript(this, aos + '/aos.js').then(() => {
                this.AOS_init();
                this.template.querySelectorAll("[data-aos]").forEach((elem) => {
                    if (this.element_is_visible(elem))
                        elem.classList.add("aos-init", "aos-animate");
                });
            });
        });

        if (this.isAllDataReady && this.leafletInitNeeded) {
            console.log('initAlgoDeLeaftles')
            loadStyle(this, leaflet + '/leaflet.css');
            loadScript(this, leaflet + '/leaflet.js').then(() => {
                this.renderMap(0);
            });
            this.leafletInitNeeded = false;
        }
    }


    @wire(retrieveActivistaFromId, { empatiaId: '$recordId' })
    wiredActivista({ error, data }) {
        if (data) {
            this.record = data;
            this.isRecordReady = true;
            console.log(this.record);
            this.buildSocialArray(this.record.Empatia_Activista__r.Citizen__r);
        }
    }


    buildSocialArray(citizen) {

        if (citizen == undefined || citizen == null)
            return;

        let facebookNoLink = false;
        let instagramNoLink = false;
        let twitterNoLink = false;
        let linkedinNoLink = false;

        let noData = "-";

        // SOCIAL NO LINKS
        if(citizen.Facebook_Link__c == undefined || citizen.Facebook_Link__c == null || citizen.Facebook_Link__c == ''
        || citizen.Usuario_Facebook__c == undefined || citizen.Usuario_Facebook__c == null || citizen.Usuario_Facebook__c == ''){
            facebookNoLink = true;
        }

        if(citizen.Instagram_Link__c == undefined || citizen.Instagram_Link__c == null || citizen.Instagram_Link__c == ''
        || citizen.Usuario_Instagram__c == undefined || citizen.Usuario_Instagram__c == null || citizen.Usuario_Instagram__c == ''){
            instagramNoLink = true;
        }

        if(citizen.Twitter_Link__c == undefined || citizen.Twitter_Link__c == null || citizen.Twitter_Link__c == ''
        || citizen.Usuario_Twitter__c == undefined || citizen.Usuario_Twitter__c == null || citizen.Usuario_Twitter__c == ''){
            twitterNoLink = true;
        }

        if(citizen.Linkedin_Link__c == undefined || citizen.Linkedin_Link__c == null || citizen.Linkedin_Link__c == ''
        || citizen.Usuario_Linkedin__c == undefined || citizen.Usuario_Linkedin__c == null || citizen.Usuario_Linkedin__c == ''){
            linkedinNoLink = true;
        }

        // SOCIAL
        this.social_array.push({"icon": this.iconsSet.iconFacebook , "link": (citizen.Facebook_Link__c ? citizen.Facebook_Link__c : '') , "usuario": (citizen.Usuario_Facebook__c ? "/" + citizen.Usuario_Facebook__c : noData), 'social_no_link': facebookNoLink});
        this.social_array.push({"icon": this.iconsSet.iconInstagram, "link": (citizen.Instagram_Link__c ? citizen.Instagram_Link__c : ''), "usuario": (citizen.Usuario_Instagram__c ? "@" + citizen.Usuario_Instagram__c : noData), 'social_no_link': instagramNoLink});
        this.social_array.push({"icon": this.iconsSet.iconTwitter  , "link": (citizen.Twitter_Link__c ? citizen.Twitter_Link__c : '')  , "usuario": (citizen.Usuario_Twitter__c ? "@" + citizen.Usuario_Twitter__c : noData), 'social_no_link': twitterNoLink});
        this.social_array.push({"icon": this.iconsSet.iconLinkedin , "link": (citizen.Linkedin_Link__c ? citizen.Linkedin_Link__c : '') , "usuario": (citizen.Usuario_Linkedin__c ? "/" + citizen.Usuario_Linkedin__c : noData), 'social_no_link': linkedinNoLink});
    }    


    @wire(retrieveNotasFromActivistaFromId, { empatiaId: '$recordId' })
    wiredNotas({ error, data }) {
        if (data) {
            this.notasArray = data;
            this.areNotasReady = true;
        }
    }

    get personalData() {

        if (this.record.Empatia_Activista__r.Citizen__r) {
            return {
                "edad": this.edad,
                "nacionalidad": this.record.Empatia_Activista__r.Citizen__r?.Nacionalidad__c ?? "-",
                "guid": this.record.Empatia_Activista__r.Citizen__r?.guid__c,
                "fecha_nac": this.record.Fecha_de_Nacimiento__c ?? "-",
                "sexo": this.record.Empatia_Activista__r.Citizen__r?.Gender__c ?? "-",
                "documento": this.record.DNI__c ?? "-",
                "cuit": this.record.Empatia_Activista__r.Citizen__r?.Cuil_Number__c ?? "-",
                "name": this.record.Empatia_Activista__r.Citizen__r?.Name ?? "-",
                "domicilio": this.record.Direccion_Completa__c ?? "-",
                "codigo_postal": this.record.Empatia_Activista__r.Citizen__r?.MailingPostalCode ?? "-",
                "telefono_fijo": this.record.Empatia_Activista__r.Citizen__r?.HomePhone ?? "-",
            }
        }

        return {
            "edad": this.edad,
            "nacionalidad": "-",
            "fecha_nac": this.record.Fecha_de_Nacimiento__c ?? "-",
            "sexo": "-",
            "documento": this.record.DNI__c ?? "-",
            "cuit": "-",
            "name": this.record.Nombre__c + ' ' + this.record.Apellido__c,
        }

    }

    get edad() {
        let edad = "-";

        if (this.record.Empatia_Activista__r.Citizen__r && this.record.Empatia_Activista__r.Citizen__r.Age_f_x__c) {
            if (this.record.Empatia_Activista__r.Citizen__r.Age_f_x__c > 0)
                edad = `${this.record.Empatia_Activista__r.Citizen__r.Age_f_x__c} AÑOS`;
            return edad;
        }

        if (Boolean(this.record.Fecha_de_Nacimiento__c)) {
            const today = new Date();
            const fechaDeNacimiento = new Date(this.record.Fecha_de_Nacimiento__c);
            //mmm segundos perdidos por año? Hago la cuenta con un año de 365,25 dias
            // milisegundos --> segundos --> minutos --> horas --> dias
            //la otra es usar ifs encadenados y comparar año, mes y dia por separado.
            let calc_age = Math.floor((today - fechaDeNacimiento) / 1000 / 60 / 60 / 24 / 365.25);
            if (calc_age > 0)
                edad = `${calc_age} AÑOS`;
        }

        return edad;
    }

    get locationLevelsData() {
        if (this.record.Empatia_Activista__r.Citizen__r) {
            return {
                //pidieron que los primeros niveles salgan del registro de empatia
                Level1Name__c: this.record.Provincia__c,
                Level2Name__c: this.record.Ciudad__c,
                Level3Name__c: this.record.Empatia_Activista__r.Citizen__r?.Level3Name__c,
                Level4Name__c: this.record.Empatia_Activista__r.Citizen__r?.Level4Name__c,
            }
        }
        return {
            Level1Name__c: this.record.Provincia__c,
            Level2Name__c: this.record.Ciudad__c,
        }
    }

    get locationData() {
        if (this.record.Empatia_Activista__r.Citizen__r) {
            // es: objContact.MailingStreet, objContact.MailingNumber__c, this.FloorApartment
            //salteando si falta alguna, con lo que haya en mailing street con la primera letra de cada palabra en mayuscula
            // + el admin level completo de nivel mas bajo
            // y si el admin level contiene la palabra comuna. Hay que mandarle CABA ** OJO, estos admin levels, deberia ser los nombres que salen del campo formula!!!
            //despues concatenar todo con espacios
            // ej: retrieveAddressLevel MailingNumber__c - FloorApartment - CABA
            let arrayDireccion = []

            arrayDireccion.push(this.record.Empatia_Activista__r.Citizen__r.MailingStreet)
            arrayDireccion.push(this.record.Empatia_Activista__r.Citizen__r.MailingNumber__c)
            arrayDireccion.push(this.record.Empatia_Activista__r.Citizen__r.MailingAppartment__c)

            let lastCompletedLvl = this.record.Empatia_Activista__r.Citizen__r.Level4Name__c ?? this.record.Empatia_Activista__r.Citizen__r.Level3Name__c ?? this.record.Empatia_Activista__r.Citizen__r.Level2Name__c ?? this.record.Empatia_Activista__r.Citizen__r.Level1Name__c;

            let lastCompletedLvl_removeComuna = lastCompletedLvl?.includes('Comuna') ? 'CABA' : lastCompletedLvl;

            arrayDireccion.push(lastCompletedLvl_removeComuna);

            let filteredArray = arrayDireccion.filter(thisValue => Boolean(thisValue));

            return {
                Address: filteredArray.join(' - '),
                MailingPostalCode: this.record.Empatia_Activista__r.Citizen__r?.MailingPostalCode
            }
        }

        return {
            Address: `${this.record.Provincia__c} - ${this.record.Ciudad__c}`
        }
    }

    get emailData() {
        return {
            send_email: "mailto:" + this.record.Email__c,
            email: this.record.Email__c,
        }
    }

    get emailAvailable() {
        return Boolean(this.record.Email__c);
    }

    get phoneAvailable() {
        if (this.record.Empatia_Activista__r.Citizen__r) {
            return Boolean(this.record.Empatia_Activista__r.Citizen__r.HomePhone);
        }
        return false;
    }

    get phoneData() {
        return {
            call_phone: 'tel:' + this.record.Empatia_Activista__r.Citizen__r?.HomePhone,
            phoneNumber: this.record.Empatia_Activista__r.Citizen__r?.HomePhone
        }
    }

    get mobileAvailable() {
        if (this.record.Empatia_Activista__r.Citizen__r) {
            return Boolean(this.record.Empatia_Activista__r.Citizen__r.MobilePhone);
        }
        return Boolean(this.record.Celular__c);
    }

    get whatsAppAvailable() {
        if (this.record.Empatia_Activista__r.Citizen__r) {
            const sameMobile = this.record.Empatia_Activista__r.Citizen__r?.MobilePhone === this.record.Celular__c?.replace('+', '');
            return this.record.Empatia_Activista__r.Citizen__r.Whatsapp__c && sameMobile;
        }
        return false;
    }

    get mobileData() {
        return {
            mobileNumber: this.record.Celular__c,
            call_mobile: "tel:" + this.record.Celular__c,
            write_whatsapp: 'https://api.whatsapp.com/send/?phone=' + this.record.Celular__c.replace('+', '') + '&text&app_absent=0'
        }
    }

    get photoAvailable() {
        if (this.record.Empatia_Activista__r.Citizen__r) {
            return Boolean(this.record.Empatia_Activista__r.Citizen__r.PhotoUrl_legacy__c);
        }
        return false;
    }

    get photoValue() {
        if (!this.record) return null;
        if (Boolean(this.record.Empatia_Activista__r.Citizen__r?.PhotoUrl_legacy__c)) return this.record.Empatia_Activista__r.Citizen__r.PhotoUrl_legacy__c;

        let tempNombre = this.record.Empatia_Activista__r.Citizen__r?.FirstName ?? this.record.Nombre__c;
        let tempApellido = this.record.Empatia_Activista__r.Citizen__r?.LastName ?? this.record.Apellido__c;

        let firstNameInitialToCaps = tempNombre ? tempNombre.toUpperCase()[0] : '';
        let lastNameInitialToCaps = tempApellido ? tempApellido.toUpperCase()[0] : '';

        return (firstNameInitialToCaps + lastNameInitialToCaps);

    }

    get relacionamientoURL() {
        let temp_url = window.location.href;
        let redirect_url;
        if (temp_url.includes('/r/Empatia__c/')) {
        redirect_url = 'argentina.lightning.force.com/lightning/r/Empatia__c/<id>/view';
        } else {
        redirect_url = 'empatia.activismo.app/s/empatia/<id>';
        }
        return `https://lab.prosumia.la/ct/embed/sf/${this.record.Empatia_Activista__r.Citizen__r?.guid__c}?url=${redirect_url}`;
    }

    get showRelacionamiento() {
        return Boolean(this.record.Empatia_Activista__r.Citizen__r);
    }

    get showMaps() {
        return Boolean(this.record.Empatia_Activista__r.Citizen__r);
    }

    get showSocialInfo() {
        return Boolean(this.social_array.length > 0);
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

    element_is_visible(elem) {
        var base_top = 75;
        var docViewTop = window.scrollY;
        var docViewBottom = docViewTop + window.innerHeight;
        var elemTop = elem.offsetTop + base_top;
        let ans = ((elemTop + 150 < docViewBottom))
        return ans;
    }

    handleGuardarNota(event) {
        console.log('event:', JSON.stringify(event.detail))
        insertNota(event.detail)
            .then((results) => {
                console.log('callback notas:',results)
                this.notasArray = results
            });
    }
}