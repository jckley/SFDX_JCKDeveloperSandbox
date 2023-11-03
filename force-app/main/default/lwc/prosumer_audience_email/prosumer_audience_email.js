import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import RESOURCES from '@salesforce/resourceUrl/prosumerModalAccion';
import RESOURCES2 from '@salesforce/resourceUrl/prosumerSendSMS';
import prosumerEmail from '@salesforce/resourceUrl/prosumerEmail';

import retrieveAndClearSessionCache from '@salesforce/apex/CacheManager.retrieveAndClearSessionCache';
import getUserCreditInformation from '@salesforce/apex/Prosumer_AudienciaPageController.getUserCreditInformation';
import consumeCredits from '@salesforce/apex/Prosumer_audience_emailController.consumeCredits';
import createCampaing from '@salesforce/apex/Prosumer_audience_emailController.createCampaing';

import { publish, MessageContext } from 'lightning/messageService';
import prosumerMessageChannel from '@salesforce/messageChannel/prosumer__c';
import getEmailList from '@salesforce/apex/prosumer_email_controller.getEmailList';
import getEmailRecord from '@salesforce/apex/prosumer_email_controller.getEmailRecord';

import modalSimple from 'c/prosumer_modal_simple';


export default class Prosumer_audience_email extends NavigationMixin(LightningElement) {
    logo = RESOURCES + "/logopng.png";
    atrasimg = RESOURCES2 + "/atrasflecha.png";
    preview = RESOURCES2 + "/preview.png";
    celular = RESOURCES2 + "/celular.png";
    confirmado = RESOURCES2 + "/confirmado.png";
    corner = RESOURCES2 + "/corner.jpg";

    prosumerEmail = prosumerEmail;

   /* currentDate = new Date();

    day = String(currentDate.getDate()).padStart(2, '0');
     month = String(currentDate.getMonth() + 1).padStart(2, '0');
     year = String(currentDate.getFullYear()).slice(-2);
    
     formattedDate = `${day}/${month}/${year}`;
     */

    loadingScreenOn = true;
    valuesFromAudiencePage;
    accountCreditInformation;

    get formatedValues() {
        return {
            //.toLocaleString('es-AR')
            number_of_people: this.valuesFromAudiencePage.number_of_people.toLocaleString('es-AR'),
            number_of_emails: this.valuesFromAudiencePage.number_of_emails.toLocaleString('es-AR'),
            email_campaing_cost: `${(this.accountCreditInformation.email_cost * this.valuesFromAudiencePage.number_of_emails).toLocaleString('es-AR')}`,
            email_cost: `${this.accountCreditInformation.email_cost.toLocaleString('es-AR')}`
        }
    }

    _listEmailsTemplate;

    get opcionesEmailsTemplate() {
        if(!this._listEmailsTemplate){
            return []
        }

        const tempArray = this._listEmailsTemplate.map(thisEmailTemplate=>{
            return {
                label:thisEmailTemplate.Name,
                value:thisEmailTemplate.Id
            }
        })

        return tempArray;
    }


    connectedCallback() {
        //a la hora de desarrollar, comentar esta parte y descomentar obtenerMockUpDeAudiencia().
        //La otra esta al final para asegurar que la pagina de carga se levante luego de inicializar las fechas. Si no, eso esta en el callback.
        this.obtenerInformacionDeAudiencia();

        getEmailList()
            .then(response => {
                this._listEmailsTemplate = response;
            })
            .catch(error => {
                console.log('Paso algo en prosumer_email_controller: ', error);
            })

        //descomentar para agilizar desarrollo
        //this.obtenerMockUpDeAudiencia();
    }

    obtenerInformacionDeAudiencia(){
        //codigo productivo a usar en prod
        const promiseCache = retrieveAndClearSessionCache({ key: 'paramsForAudienceLWC' })
        const promiseAccountValues = getUserCreditInformation()

        Promise.all([promiseCache, promiseAccountValues]).then(values => {
            if (!values[0] || !values[1]) {
                console.log('hubo problemas al durante el connected callback');
                console.log('cache: ', values[0]);
                console.log('acc info: ', values[1]);
                return;
            }
            this.valuesFromAudiencePage = JSON.parse(values[0]);
            this.accountCreditInformation = values[1];
            this.loadingScreenOn = false;
        });
    }

    obtenerMockUpDeAudiencia(){
        //para testear: para agilizar el proceso de desarrollo, descomentar este bloque de codigo que permite actualizar la pagina sin tener que pasar por la de audiencia
        
        this.accountCreditInformation = { sms_cost: 100, ivr_cost: 100, email_cost: 150, accountCredits: 500000 };
        this.valuesFromAudiencePage = {
            number_of_people: 5,
            number_of_mobiles: 1,
            number_of_fijos: 2,
            number_of_emails: 3,
            mobilePhoneQuery_forMc: {"query":"q = load \"0FbDa000000GGyWKAW/0FcDa00000151x8KAA\";q = filter q by 'fx_TerritoryTree' like \"%a2LDa0000015GD9%\"&&'fx_TerritoryTree' like \"%a2LDa0000015GIt%\";q = filter q by MobilePhone is not null;q = foreach q generate guid__c as 'guid__c',Id as 'Id',MobilePhone as 'MobilePhone';q = limit q 50;"},
            homePhoneQuery_forMc: {"query":"q = load \"0FbDa000000GGyWKAW/0FcDa00000151x8KAA\";q = filter q by 'fx_TerritoryTree' like \"%a2LDa0000015GD9%\"&&'fx_TerritoryTree' like \"%a2LDa0000015GIt%\";q = filter q by HomePhone is not null;q = foreach q generate guid__c as 'guid__c',Id as 'Id',HomePhone as 'HomePhone';q = limit q 50;"},
            emailQuery_forMc: {"query":"q = load \"0FbDa000000GGyWKAW/0FcDa00000151x8KAA\";q = filter q by 'fx_TerritoryTree' like \"%a2LDa0000015GD9%\"&&'fx_TerritoryTree' like \"%a2LDa0000015GIt%\";q = filter q by Email is not null;q = foreach q generate guid__c as 'guid__c',Id as 'Id',Email as 'Email';q = limit q 50;"},
            //type_of_campaing devuelve uno de estos:  ['smsCampaing','ivrCampaignMobile','ivrCampaignFijo','emailCampaign']
            type_of_campaign: 'emailCampaign',
            filters: ["Tierra del Fuego", "Antártida Argentina", "Generación X"]
        }

        this.loadingScreenOn = false;
    }

    emailId;
    async handleEmailTemplateChange (event) {
        const emailTemplateId = event.target.value;
        this.emailId = emailTemplateId;
        const emailRecord = await getEmailRecord({ emailid: emailTemplateId })
        const html = emailRecord.HTML__c;

        const mainNode = this.template.querySelector("[data-placeholder]");

        //clear old html
        while (mainNode.firstChild) {
            mainNode.removeChild(mainNode.firstChild);
        }

        const template = document.createElement('template');
        template.innerHTML = html;
        mainNode.appendChild(template.content)
    }

    tituloCampania;
    handleNombreCampañaChange (event) {
        this.tituloCampania = event.detail.value;
    }

    asuntoCampaña;
    handleAsuntoCampañaChange (event) {
        this.asuntoCampaña = event.detail.value;
    }

    nombreRemitente;
    handleNombreRemitenteChange (event) {
        this.nombreRemitente = event.detail.value;
    }

    emailRemitente;
    handleEmailRemitenteChange (event) {
        this.emailRemitente = event.detail.value;
    }


    @wire(MessageContext)
    messageContext;

    async handleEnviar() {
        const result = await modalSimple.open({
            size: 'small',
            label: 'Confirmar envio',
            titulo:`Está por enviar ${this.formatedValues.number_of_emails} llamadas IVR`,
            cuerpo:`Esta campaña costará ${this.formatedValues.email_campaing_cost} creditos de su cuenta Prosumer.\r\n
                            Una vez ejecutada no podrá revertirse`,
            textoBotonTrue:'Enviar emails',
            textoBotonFalse:'Cancelar',
        });

        console.log('modal results: ', result)
        if (!result) return;

        
        const totalOfMobiles = this.valuesFromAudiencePage.number_of_mobiles;

        const haveCredits = await consumeCredits({ totalOfMobiles: totalOfMobiles });

        if (!haveCredits) return;
        
        const payload = { refreshCredits: true };
        publish(this.messageContext, prosumerMessageChannel, payload);

        const createCampaingParams = {
            titulo: this.tituloCampania,
            saql: this.valuesFromAudiencePage.emailQuery_forMc.query,
            filtros: JSON.stringify(this.valuesFromAudiencePage.filters),
            emailId: this.emailId,
            costo: this.accountCreditInformation.email_cost * this.valuesFromAudiencePage.number_of_emails,
            cantidadEmails: this.valuesFromAudiencePage.number_of_emails,
            personas: this.valuesFromAudiencePage.number_of_people,
            asuntoCampania: this.asuntoCampaña,
            nombreRemitente: this.nombreRemitente,
            emailRemitente: this.emailRemitente
        }


        let campaingId;
        try {
            campaingId = await createCampaing(createCampaingParams);
        } catch (error) {
            console.log('Error al crear la campaña: ' + JSON.stringify(error));
            return;
        }
        console.log('Se creo la campaña: ', campaingId);
        // aca sigue el export
    }

    handleCancelar() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Audiencia__c'
            },
        });
    }
    
    get disableEnviarCampaña () {
        const creditosInsuficientes = (this.accountCreditInformation.email_cost * this.valuesFromAudiencePage.number_of_emails) > this.accountCreditInformation.accountCredits;
        const templateEmailIncorrecto = !Boolean(this.emailId);
        const tituloCampañaIncorrecto = !Boolean(this.tituloCampania);
        const asuntoIncorrecto = !Boolean(this.asuntoCampaña);
        const remitenteIncorrecto = !Boolean(this.nombreRemitente);
        const emailRemitenteIncorrecto = !Boolean(this.emailRemitente);
        return creditosInsuficientes || templateEmailIncorrecto || tituloCampañaIncorrecto || asuntoIncorrecto || remitenteIncorrecto || emailRemitenteIncorrecto
    }

}