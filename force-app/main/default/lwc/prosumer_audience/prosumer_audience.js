import { LightningElement, api, track, wire, } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

// import sendMessage from '@salesforce/apex/MensajesController.sendMessage';
// import sendApprovedMessage from '@salesforce/apex/MensajesController.sendApprovedMessage';
// import sendMessageToMarketingCloud from '@salesforce/apex/MensajesController.sendMessageToMarketingCloud';



// borrado a PROD
import sendSingleMessageToMarketingCloud from '@salesforce/apex/MensajesController.sendSingleMessageToMarketingCloud';
// borrado a PROD
import insertExportToMarketingCloudForMobile from '@salesforce/apex/ExportController.insertExportToMarketingCloudForMobile';


import prosumerAceptarPrueba from 'c/prosumer_modal_aceptar_prueba';
import prosumerEnviarCampaña from 'c/prosumer_modal_enviar_campana_sms';

import RESOURCES from '@salesforce/resourceUrl/prosumerModalAccion';
import RESOURCES2 from '@salesforce/resourceUrl/prosumerSendSMS';

import retrieveAndClearSessionCache from '@salesforce/apex/CacheManager.retrieveAndClearSessionCache';
import getUserCreditInformation from '@salesforce/apex/Prosumer_AudienciaPageController.getUserCreditInformation';
import consumeCredits from '@salesforce/apex/Prosumer_audience_controller.consumeCredits';
import createCampaing from '@salesforce/apex/Prosumer_audience_controller.createCampaing';

import { publish, MessageContext } from 'lightning/messageService';
import prosumerMessageChannel from '@salesforce/messageChannel/prosumer__c';

export default class Prosumer_audience extends NavigationMixin(LightningElement) {

   


    logo = RESOURCES + "/logopng.png";
    atrasimg = RESOURCES2 + "/atrasflecha.png";
    preview = RESOURCES2 + "/preview.png";
    celular = RESOURCES2 + "/celular.png";
    confirmado = RESOURCES2 + "/confirmado.png";
    corner = RESOURCES2 + "/corner.jpg";


    @track counterTextTA = '160';
    @track counterClassTA = 'counter-green';

   @track testedNumber;

    loadingScreenOn = true;
    valuesFromAudiencePage;
    accountCreditInformation;

    get formatedValues() {
        return {
            //.toLocaleString('es-AR')
            number_of_people: this.valuesFromAudiencePage.number_of_people.toLocaleString('es-AR'),
            number_of_mobiles: this.valuesFromAudiencePage.number_of_mobiles.toLocaleString('es-AR'),
            sms_campaing_cost: `${(this.accountCreditInformation.sms_cost * this.valuesFromAudiencePage.number_of_mobiles).toLocaleString('es-AR')}`,
            sms_cost: `${this.accountCreditInformation.sms_cost.toLocaleString('es-AR')}`
        }
    }


currentDay = new Date().toLocaleDateString('es-AR', { weekday: 'long' }).replace(/^\w/, c => c.toUpperCase());
    currentTime24 = new Date().toLocaleTimeString('es-AR', { hour: 'numeric', minute: 'numeric' });

    currentTime12 = new Date().toLocaleTimeString('es-AR', { hour: 'numeric', minute: 'numeric', hour12: true }).replace(/\./g,'').toUpperCase();


    connectedCallback() {
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




       // get the current minute
    let currentMinute = new Date().getMinutes();

    // set a timeout to update the displayed time when the minute changes
    setTimeout(() => {
      // check if the minute has changed
      if (new Date().getMinutes() !== currentMinute) {
        // update the displayed time
        this.updateTime();
      } else {
        // if the minute has not changed, set another timeout to check again in a second
        setTimeout(() => {
          this.checkTime();
        }, 1000);
      }
    }, (60 - new Date().getSeconds()) * 1000);

    }


    updateTime() {
        this.currentTime24 = new Date().toLocaleTimeString('es-AR', { hour: 'numeric', minute: 'numeric' });
        this.currentTime12 = new Date().toLocaleTimeString('es-AR', { hour: 'numeric', minute: 'numeric', hour12: true }).replace(/\./g,'').toUpperCase();
        // get the new current minute
        let currentMinute = new Date().getMinutes();
        // set a timeout to update the displayed time when the minute changes
        setTimeout(() => {
          // check if the minute has changed
          if (new Date().getMinutes() !== currentMinute) {
            // update the displayed time
            this.updateTime();
          } else {
            // if the minute has not changed, set another timeout to check again in a second
            setTimeout(() => {
              this.checkTime();
            }, 1000);
          }
        }, (60 - new Date().getSeconds()) * 1000);
      }


    forzar_gsm7_charset(text) {
        // let validos = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789:;<=>?¡¿!\"#¤%&()'*+,-./ÄÖÑÜ§äöñüà@£$¥èéùìòÇØøÅåΔ_ΦΓΛΩΠΨΣΘΞÆæßÉ€^{}[]~|\n"
        let validos = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789:;<=>?¡¿!#%&()‘*+,-./@$\n"
        let new_text = "";
        for (let i = 0 ; i < text.length ; i++) {
            let char = text[i];
            if (validos.indexOf(char) >= 0)
                new_text += char;
        }
        return new_text;
    }

    get_message_lenght(text){
        let dos_bytes = "€{}[]~|";
        let length = 0;
        for (let i = 0 ; i < text.length ; i++) 
            length += dos_bytes.indexOf(text[i]) >= 0 ? 2 : 1;
        return length;
    }

    updateTextArea(event) {
        event.target.value = this.forzar_gsm7_charset(event.target.value);
        const textarea = event.target;
        const remainingChars = 160 - this.get_message_lenght(event.target.value);

        if (remainingChars >= 0) {
            this.counterTextTA = `${remainingChars}`;
            this.counterClassTA = 'counter-green';
        } else {
            this.counterTextTA = `${Math.abs(remainingChars)}`;
            this.counterClassTA = 'counter-red';
        }


        const texto = textarea.value;
        const longitud = texto.length;
        
        if (longitud > 160) {
          const warningText = texto.substring(160);
          const normalText = texto.substring(0, 160);
          const startPosition = textarea.selectionStart;
          const endPosition = textarea.selectionEnd;
          textarea.value = normalText;
          textarea.value += warningText;
          textarea.setSelectionRange(startPosition, endPosition);
          textarea.classList.add('warning');
        } else {
          textarea.classList.remove('warning');
        }


        const mensaje = this.template.querySelector('.slds-textarea');
        const previewBox = this.template.querySelector('.previewBox');
        const previewParent = this.template.querySelector('.previewParent');
        
        if (mensaje.value.length > 0) {
          previewBox.innerHTML = mensaje.value;
          previewParent.style.opacity = 1;
        } else {
          previewBox.innerHTML = mensaje.value;
          previewParent.style.opacity = 0;
        }


        textarea;
        const title = this.template.querySelector('.title');
        const numberToTest = this.template.querySelector('.numberToTest');

        const enviarPrueba = this.template.querySelector('.enviarPrueba');
        const enviarConfirmar = this.template.querySelector('.enviarConfirmar');

        // preguntar por longitud de textarea y nombre de la campaña
        //const textarea = this.template.querySelector('textarea');

        if (longitud > 0 && longitud <= 160 && numberToTest.value.length > 0){
                enviarPrueba.disabled = false;
        }else{
                enviarPrueba.disabled = true;
        }

        if(longitud > 0 && longitud <= 160 && title.value.length > 0 && title.value.length <= 35){
                enviarConfirmar.disabled = false;
        }else{
                enviarConfirmar.disabled = true;
        }

    }

    @track counterTextI = '35';
    @track counterClassI = 'counter-green';

    tituloCampania;

    updateInputTitulo() {
        const inputTitulo = this.template.querySelector('.title');
        const remainingChars = 35 - inputTitulo.value.length;
        this.tituloCampania = inputTitulo.value;

        if (remainingChars >= 0) {
            this.counterTextI = `${remainingChars}`;
            this.counterClassI = 'counter-green';
        } else {
            this.counterTextI = `${Math.abs(remainingChars)}`;
            this.counterClassI = 'counter-red';
        }



        

        const texto = inputTitulo.value;
        const longitud = texto.length;
        
        if (longitud > 35) {
         
          inputTitulo.classList.add('warning');
        } else {
            inputTitulo.classList.remove('warning');
        }




        // preguntar por text y SMS numero
        // SMS numero ya esta
        // falta longitud de textarea


        const textarea = this.template.querySelector('textarea');

        const enviarConfirmar = this.template.querySelector('.enviarConfirmar');
      

       if (longitud > 0 && longitud <= 35){
            if(textarea.value.length > 0 && textarea.value.length <= 160){
                enviarConfirmar.disabled = false;
            }
       }else{
            enviarConfirmar.disabled = true;
       }

      
    }

    updateInputPrueba() {
        const textarea = this.template.querySelector('textarea');
        const numberToTest = this.template.querySelector('.numberToTest');

        const enviarPrueba = this.template.querySelector('.enviarPrueba');


      
       if (numberToTest.value.length > 0){
            if(textarea.value.length > 0 && textarea.value.length <= 160){
                enviarPrueba.disabled = false;
            }
       }else{
         enviarPrueba.disabled = true;
       }


    }


    strMessage;
    strPhoneNumber;

    sms_action_selected(campaignId) {
        console.log("sms_action_selected");
        console.log("campaignId = " + campaignId);

        insertExportToMarketingCloudForMobile({
            campaignId: campaignId
        }).then(data => {
            console.log(`data = ${data}`);
            console.log(JSON.stringify(data));
        }).catch(error => {
            error = ['An error has occurred while generating a new export. Contact to a system administrator'];
        });
        // insertExportToMarketingCloudForMobile({
        //     strName: "DAC_TEST_DATA_EXTENSION_FOR_PROSUMER_MODAL"
        //     , strSAQL: "q = load \"Ciudadanos\"; q = foreach q generate 'Id' as 'Id', 'UUID__c' as 'UUID__c'; q = limit q 10;"
        //     , strDataExtensionName: "DAC_TEST_DATA_EXTENSION_FOR_PROSUMER_MODAL"
        //     , strMessage
        // }).then(data => {
        //     console.log(`data = ${data}`);
        //     console.log(JSON.stringify(data));
        // }).catch(error => {
        //     error = ['An error has occurred while generating a new export. Contact to a system administrator'];
        // });

    }

    pruebaEnviada = false;

    async sendTestMessage() {
        console.log("Entering sendTestMessage");
        console.log("strPhoneNumber = ", this.strPhoneNumber);
        console.log("strMessage = ", this.strMessage);

        // let data_extension_name = 'DAC_FOR_SMS_TEST';
        // let data_extension_external_key = '369917EA-834F-4D21-915F-0051AEF9B2AE';

        const result = await prosumerAceptarPrueba.open({
            size: 'small',
            numeroTelefono: `${this.strPhoneNumber}`,
            costoPrueba: this.accountCreditInformation.sms_cost
        });

        if (!result) return;

        const haveCredits = await consumeCredits({ totalOfMobiles: 1 });

        if (!haveCredits) return;

        const payload = { refreshCredits: true };
        publish(this.messageContext, prosumerMessageChannel, payload);

        sendSingleMessageToMarketingCloud({
            strMessage: this.strMessage
            , strPhoneNumber: this.strPhoneNumber
        })
            .then(sendSingleMsjResult => {
                console.log('envio de prueba oK: ' + sendSingleMsjResult);
                this.showConfirmation();
            })
            .catch(sendSingleMsjError => {
                console.log('sendSingleMsjError: ' + sendSingleMsjError);
            });

    }

    showConfirmation(){
        this.testedNumber = this.strPhoneNumber;
        const confirmado = this.template.querySelector('.confirmado');
        confirmado.style.opacity = "1";
        confirmado.style.height = "61px";
        const input = this.template.querySelector('.numberToTest');
        input.value = "";
        const button = this.template.querySelector('.enviarPrueba');
        button.disabled = true;
    }

    hideConfirmation(){
        const confirmado = this.template.querySelector('.confirmado');
        confirmado.style.opacity = "0";
        confirmado.style.height = "0px";
    }

    @wire(MessageContext)
    messageContext;

    async handleEnviar() {
        const result = await prosumerEnviarCampaña.open({
            size: 'small',
            cantidadMensajes: this.formatedValues.number_of_mobiles,
            costoPrueba: this.formatedValues.sms_campaing_cost
        });

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
            msj: this.strMessage,
            costo: this.accountCreditInformation.sms_cost * this.valuesFromAudiencePage.number_of_mobiles,
            moviles: this.valuesFromAudiencePage.number_of_mobiles,
            personas: this.valuesFromAudiencePage.number_of_people
        }

        console.log(createCampaingParams);
        let campaingId;
        try {
            campaingId = await createCampaing(createCampaingParams);
        } catch (error) {
            console.log('Error al crear la campaña: ' + JSON.stringify(error));
            return;
        }

        console.log('ENVIAR CAMPAÑA, PENDIENTE COMPLETAR', campaingId);
        const saqlForExport = this.valuesFromAudiencePage.emailQuery_forMc.query;
        const msjForExport = this.strMessage;
        //const exportResutl = createExport({saql: saqlForExport,msj: msjForExport, campaingId: campaingId});
        //if (!exportResutl) return; //por ahi un modal diciendo que hubo un error? Si salio todo bien, se saltea esta guard y navega a la prxoima pagina.
        this.sms_action_selected(campaingId);

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Dashboard_Activaciones__c'
            },
        });
    }

    handleCancelar() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Audiencia__c'
            },
        });
    }

    handleMobileChange(event) {
        this.strPhoneNumber = event.target.value;
        console.log(this.strPhoneNumber);


    }

  

    handleMessageChange(event) {
        this.strMessage = event.target.value;
        console.log(this.strMessage);
    }

}