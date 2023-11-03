import { LightningElement, track, wire, } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import prosumerAceptarPrueba from 'c/prosumer_modal_aceptar_prueba_ivr';
import prosumerEnviarCampaña from 'c/prosumer_modal_enviar_campana_ivr';

import multiSlider from 'c/multiSlider';

import RESOURCES from '@salesforce/resourceUrl/prosumerModalAccion';
import RESOURCES2 from '@salesforce/resourceUrl/prosumerSendSMS';
import RESOURCES3 from '@salesforce/resourceUrl/prosumerAudiencia';

import retrieveAndClearSessionCache from '@salesforce/apex/CacheManager.retrieveAndClearSessionCache';
import getUserCreditInformation from '@salesforce/apex/Prosumer_AudienciaPageController.getUserCreditInformation';
import consumeCredits from '@salesforce/apex/Prosumer_audience_controller.consumeCredits';
import createCampaignIVR from '@salesforce/apex/Prosumer_audience_controller.createCampaignIVR';
import insertExportToSondeosIVR from '@salesforce/apex/ExportController.insertExportToSondeosIVR';

import { publish, MessageContext } from 'lightning/messageService';
import prosumerMessageChannel from '@salesforce/messageChannel/prosumer__c';


import prosumerFileInput from 'c/prosumer_fileinput_modal';
import getContentVersionDataAsString from '@salesforce/apex/Prosumer_fileinput_modal_Controller.getContentVersionDataAsString';

import PREVIEW from '@salesforce/resourceUrl/prosumerIVR';



export default class Prosumer_audience_ivr extends NavigationMixin(LightningElement) {
    @track fecha_inicio;
    @track fecha_finalizacion;
    hora_inicio;
    hora_finalizacion;
    fecha_inicio_input;
    fecha_finalizacion_input;

    versiondataString;

    logo = RESOURCES + "/logopng.png";
    atrasimg = RESOURCES2 + "/atrasflecha.png";

    preview = PREVIEW + "/iphone_home.jpg";
    audioLlamada = PREVIEW + "/incoming.mp3";

    celular = RESOURCES2 + "/celular.png";
    telefono = RESOURCES3 + "/telefono.png";

    confirmado = RESOURCES2 + "/confirmado.png";
    corner = RESOURCES2 + "/corner.jpg";

    @track counterTextTA = '160';
    @track counterClassTA = 'counter-green';

    @track testedNumber;

    loadingScreenOn = true;
    valuesFromAudiencePage;
    accountCreditInformation;

    reader;

    type_of_campaign;

    currentDay = new Date().toLocaleDateString('es-AR', { weekday: 'long' }).replace(/^\w/, c => c.toUpperCase());
    currentTime24 = new Date().toLocaleTimeString('es-AR', { hour: 'numeric', minute: 'numeric' });
    // currentTime12 = new Date().toLocaleTimeString('es-AR', { hour: 'numeric', minute: 'numeric', hour12: true }).replace(/\./g, '').toUpperCase();
  
    currentDate = new Date().toLocaleDateString('es-AR', { day: 'numeric', month: 'long' });

    @track counterTextI = '35';
    @track counterClassI = 'counter-green';

    tituloCampania;

    strPhoneNumber;

    get hoy() {
        const today = new Date();
        const year = today.getFullYear();
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const day = String(today.getDate()).padStart(2, '0');

        const formattedDate = `${year}-${month}-${day}`;
        console.log(formattedDate); // Output: "2023-06-28"

        return {
            formattedDate: formattedDate
        };
    }


    get formatedValues() {
        // console.log("in formatedValues....");
        let campaign_cost = 0;
        if (this.valuesFromAudiencePage.type_of_campaign == 'ivrCampaignMobile') {
            campaign_cost = this.accountCreditInformation.ivr_cost * this.valuesFromAudiencePage.number_of_mobiles;
            this.placeholderPrueba = "Ej. 11 15 54021355 (Cod. Área + 15 + Nro.)";
        }
        if (this.valuesFromAudiencePage.type_of_campaign == 'ivrCampaignFijo') {
            campaign_cost = this.accountCreditInformation.ivr_cost * this.valuesFromAudiencePage.number_of_fijos;
            this.placeholderPrueba = "Ej. 11 54021355 (Cod. Área + Nro.) Sin 15";
        }
        // console.log(this.valuesFromAudiencePage.mobilePhoneQuery_forMc);
        // console.log(this.valuesFromAudiencePage.mobilePhoneQuery_forMc.query);

        return {
            //.toLocaleString('es-AR')
            number_of_people: this.valuesFromAudiencePage.number_of_people.toLocaleString('es-AR'),
            number_of_mobiles: this.valuesFromAudiencePage.number_of_mobiles.toLocaleString('es-AR'),
            number_of_fijos: this.valuesFromAudiencePage.number_of_fijos.toLocaleString('es-AR'),
            type_of_campaign: this.valuesFromAudiencePage.type_of_campaign,
            campaign_cost: `${campaign_cost.toLocaleString('es-AR')}`,
            ivr_cost: `${this.accountCreditInformation.ivr_cost.toLocaleString('es-AR')}`
        }
    }

    renderedCallback (){
       /* console.log("ACCOUNT CONFIGURATION IS OK??????? TEST >>>>>> "+this.accountCreditInformation.ivr_cost);
        console.log("this.valuesFromAudiencePage.number_of_mobiles IS OK??????? TEST >>>>>> "+this.valuesFromAudiencePage.number_of_mobiles);
        console.log("this.valuesFromAudiencePage.number_of_fijos IS OK??????? TEST >>>>>> "+this.valuesFromAudiencePage.number_of_fijos);

        console.log("this.typeof campaign IS OK??????? TEST >>>>>> "+this.type_of_campaign);

        console.log("this.typeof campaign IS OK??????? TEST >>>>>> "+this.formatedValues.type_of_campaign);
    
        console.log("KAI TEST");

        let campaign_cost = 0;
        if (this.type_of_campaign == 'ivrCampaignMobile') {
            campaign_cost = this.accountCreditInformation.ivr_cost * this.valuesFromAudiencePage.number_of_mobiles;
        }
        if (this.type_of_campaign == 'ivrCampaignFijo') {
            campaign_cost = this.accountCreditInformation.ivr_cost * this.valuesFromAudiencePage.number_of_fijos;
        }

        console.log("mobile_selected??????? TEST >>>>>> "+mobile_selected);
        console.log("fijo??????? TEST >>>>>> "+fijo_selected);
        console.log("mobile_selected()??????? TEST >>>>>> "+mobile_selected());
        console.log("fijo()??????? TEST >>>>>> "+fijo_selected());*/
       
    }

    connectedCallback() {
 
        //a la hora de desarrollar, comentar esta parte y descomentar obtenerMockUpDeAudiencia().
        //La otra esta al final para asegurar que la pagina de carga se levante luego de inicializar las fechas. Si no, eso esta en el callback.
        this.obtenerInformacionDeAudiencia();

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


        // SET INITIAL VALUES FOR DATES

        this.fecha_inicio = new Date();
        this.fecha_finalizacion = new Date();
        this.hora_inicio = '09:00';
        this.hora_finalizacion = '19:00';

        let day = `0${this.fecha_inicio.getDate()}`.slice(-2);
        let month = `0${this.fecha_inicio.getMonth() + 1}`.slice(-2);
        let year = this.fecha_inicio.getFullYear();

        this.fecha_inicio_input = `${year}-${month}-${day}`;
        this.fecha_finalizacion_input = `${year}-${month}-${day}`;

        //descomentar para agilizar desarrollo
        //this.obtenerMockUpDeAudiencia();
        //this.handleAutoPlay();
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
        
        this.accountCreditInformation = { sms_cost: 100, ivr_cost: 100, email_cost: 100, accountCredits: 29557000 };
        this.valuesFromAudiencePage = {
            "number_of_people": 1,
            "number_of_mobiles": 1,
            "saql": {
                "query": "q = load \"0FbDa000000GGyWKAW/0FcDa00000151x8KAA\";q = filter q by 'fx_TerritoryTree' like \"%a2LDa0000015GD9%\"&&'fx_TerritoryTree' like \"%a2LDa0000015GIt%\"&&'Audiencia_Generaciones__c' == \"GENERACION X\";q = foreach q generate guid__c as 'guid__c',Id as 'Id',MobilePhone as 'MobilePhone';q = limit q 50;"
            },
            "filters": ["Tierra del Fuego", "Antártida Argentina", "Generación X"]
        }

        this.loadingScreenOn = false;
    }


    updateTime() {
        this.currentTime24 = new Date().toLocaleTimeString('es-AR', { hour: 'numeric', minute: 'numeric' });
        this.currentTime12 = new Date().toLocaleTimeString('es-AR', { hour: 'numeric', minute: 'numeric', hour12: true }).replace(/\./g, '').toUpperCase();
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

        const enviarConfirmar = this.template.querySelector('.enviarConfirmar');

        if (longitud > 0 && longitud <= 35) {
            enviarConfirmar.disabled = false;
        } else {
            enviarConfirmar.disabled = true;
        }
    }

    updateInputPrueba() {
        const numberToTest = this.template.querySelector('.numberToTest');
        const enviarPrueba = this.template.querySelector('.enviarPrueba');

        enviarPrueba.disabled = (numberToTest.value.length >= 10) ? false : true;
    }


    // async sendTestMessage() {
    //     const numberToTest = this.template.querySelector('.numberToTest').value;

    //     if (numberToTest.length < 10)
    //         return;

    //     const result = await prosumerAceptarPrueba.open({
    //         size: 'small',
    //         numeroTelefono: `${this.strPhoneNumber}`,
    //         costoPrueba: this.accountCreditInformation.sms_cost
    //     });

    //     if (!result) return;

    //     const haveCredits = await consumeCredits({ totalOfMobiles: 1 });

    //     if (!haveCredits) return;

    //     const payload = { refreshCredits: true };
    //     publish(this.messageContext, prosumerMessageChannel, payload);


    //     const file = this.fileInMemory;
    //     console.log("in sendTestMessage... file = ", file);
    //     if(!file) {
    //         console.log('Para la prueba, por ahora, hay que cargar un archivo desde 0')
    //         this.sendTestMessage2();
    //         return;
    //     }
    //     const reader = new FileReader();
    //     reader.onload = (e) => {
    //         let fecha_hoy = new Date();
    //         let day = `0${fecha_hoy.getDate()}`.slice(-2);
    //         let month = `0${fecha_hoy.getMonth() + 1}`.slice(-2);
    //         let year = fecha_hoy.getFullYear();

    //         let fecha_desde = `${day}-${month}-${year}`;
    //         let fecha_hasta = `${day}-${month}-${year}`;

    //         let url = 'https://cmpapi.sondeosglobal.com/campaign/create';

    //         const formData = new FormData();
    //         formData.append(
    //             'request',
    //             JSON.stringify({
    //                 auth: { usuario: 'SmartIVR', clave: 'MmEwY2Q5' },
    //                 datosCampania: {
    //                     nombre: 'PruebaTESTAPI',
    //                     fechaDesde: fecha_desde,
    //                     fechaHasta: fecha_hasta,
    //                     horarios: [
    //                         { dia: 'Lunes', desde: '00:10', hasta: '23:50' },
    //                         { dia: 'Martes', desde: '00:10', hasta: '23:50' },
    //                         { dia: 'Miercoles', desde: '00:10', hasta: '23:50' },
    //                         { dia: 'Jueves', desde: '00:10', hasta: '23:50' },
    //                         { dia: 'Viernes', desde: '00:10', hasta: '23:50' },
    //                         { dia: 'Sabado', desde: '00:10', hasta: '23:50' },
    //                         { dia: 'Domingo', desde: '00:10', hasta: '23:50' }
    //                     ],
    //                     numero: 'TramaCelular',
    //                     tipo: 'audio'
    //                 }
    //             })
    //         );

    //         const audio = reader.result;
    //         console.log("audio length = ", audio.byteLength);

    //         const audioFile = new File([audio], 'audio_pcm_16bit_mono_8khz.wav', { type: 'audio/wav' });
    //         console.log('AudioFile CREADO NUEVO: ', audioFile);
    //         console.log('AudioFile ORIGINAL: ', file);
    //         const lote = 'Telefono;Nombre\n' + numberToTest + ';John\n'
    //         const loteFile = new File([lote], 'audiencia.csv', { type: 'text/csv' });

    //         formData.append('audio', audioFile);   //this is what's working

    //         formData.append('lote', loteFile);

    //         fetch(url, {
    //             method: 'POST',
    //             body: formData
    //         })
    //             .then(response => response.json())
    //             .then(data => {
    //                 console.log('Audio de prueba enviado correctamente: ', data);
    //             })
    //             .catch(error => {
    //                 console.error('Hubo problemas con el audio de prueba: ', error);
    //             });

    //     }
    //     reader.readAsArrayBuffer(file);
    // }

    formattedTime = "00:00";

    intervalId = null;
 
   

    updateTime() {
        // Obtener el valor actual del contador

        const [minutes, seconds] = this.formattedTime.split(':').map(Number);
        let totalSeconds = minutes * 60 + seconds;
    
        // Incrementar un segundo
        totalSeconds += 1;
    
        // Calcular minutos y segundos
        const newMinutes = Math.floor(totalSeconds / 60);
        const newSeconds = totalSeconds % 60;
    
        // Formatear el tiempo y actualizar el valor del contador
        this.formattedTime = `${newMinutes}:${String(newSeconds).padStart(2, '0')}`;
    }

    stopCounter() {
        // Detener el intervalo
        clearInterval(this.intervalId);
    }



    prev1 = PREVIEW + "/iphone_incoming.jpg"; // Cambio la imagen del celular
    prev2 = PREVIEW + "/iphone_call.jpg"; // Cambio la imagen del celular
    prev3 = PREVIEW + "/iphone_home.jpg"; // Cambio la imagen del celular

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

    hideConfirmation() {
        const confirmado = this.template.querySelector('.confirmado');
        confirmado.style.opacity = "0";
        confirmado.style.height = "0px";
    }

    handlePlay(){ // Para iniciar la animación en el Audio Play que se muestra en la columna de la izquierda
        const audioElement = this.template.querySelector('.loadAudio');
        console.log('Reproducción iniciada');
        audioElement.pause();
        console.log('Reproducción detenida');
        this.animacionIVR();
    }

    animacionIVR(){
         // ---------
        // Animacion empieza
        // ---------

       

        setTimeout(() => {

        const prev1 = this.template.querySelector('.prev1');
        const prev2 = this.template.querySelector('.prev2');
        const prev3 = this.template.querySelector('.prev3');

       // this.preview = PREVIEW + "/iphone_incoming.jpg"; // Cambio la imagen del celular

       //prev3.style.opacity = "0";
       prev1.style.opacity = "1";

        const datetimeElements = this.template.querySelectorAll('.datetime');
        for (let i = 0; i < datetimeElements.length; i++) {
            datetimeElements[i].style.opacity = '0'; // Oculto fecha y hora
          }

        const audioLlamada = this.template.querySelector('.audioLlamada');
        audioLlamada.play();

        setTimeout(() => {

        audioLlamada.pause();
        
       // this.preview = PREVIEW + "/iphone_call.jpg"; // Cambio la imagen del celular

       //prev1.style.opacity = "0";
       prev2.style.opacity = "1";
       
        const contador = this.template.querySelector('.contador');
        contador.style.opacity = '1'; // Hago aparecer el contador
        this.formattedTime = "00:00";
         // Iniciar el contador
         this.intervalId = setInterval(() => {
            this.updateTime();
         }, 1000); // Actualizar cada segundo

           // Obtener referencia al reproductor de audio
         const audioPlayer = this.template.querySelector('.previewAudio2');

          // Reproducir audio al iniciar el contador
        audioPlayer.play();

         // Detectar el evento 'ended' del audio para detener el contador
         audioPlayer.addEventListener('ended', () => {

            setTimeout(() => {

               this.stopCounter();

            //   this.preview = PREVIEW + "/iphone_home.jpg"; // Cambio la imagen de fondo

            prev1.style.opacity = "0";
            prev2.style.opacity = "0";
            prev3.style.opacity = "1";

               for (let i = 0; i < datetimeElements.length; i++) {
                datetimeElements[i].style.opacity = '1'; // Aparece fecha y hora
              }
              contador.style.opacity = '0'; // Hago desaparecer el contador

            }, 2000); 

         });


        }, 5000); 

        }, 1000); 

        // ---------
        // Animacion termina
        // ---------
    }

    async sendTestMessage() {
        const numberToTest = this.template.querySelector('.numberToTest').value;

        if (numberToTest.length < 10)
            return;

        const result = await prosumerAceptarPrueba.open({
            size: 'small',
            numeroTelefono: `${this.strPhoneNumber}`,
            costoPrueba: this.accountCreditInformation.ivr_cost
        });

        this.showConfirmation();

       this.animacionIVR();

        if (!result) return;

        const haveCredits = await consumeCredits({ totalOfMobiles: 1 });

        if (!haveCredits) return;

        const payload = { refreshCredits: true };
        publish(this.messageContext, prosumerMessageChannel, payload);


        const file = this.fileInMemory;
        console.log("in sendTestMessage... file = ", file);

        let audio = Uint8Array.from(atob(this.versiondataString), x => x.charCodeAt(0));
        this.sendTestMessageToSondeos(audio, numberToTest);

    }


    async sendTestMessageToSondeos(audio, numberToTest) {
        console.log("in sendTestMessageToSondeos.......");

        let fecha_hoy = new Date();
        let day = `0${fecha_hoy.getDate()}`.slice(-2);
        let month = `0${fecha_hoy.getMonth() + 1}`.slice(-2);
        let year = fecha_hoy.getFullYear();

        let fecha_desde = `${day}-${month}-${year}`;
        let fecha_hasta = `${day}-${month}-${year}`;

        let url = 'https://cmpapi.sondeosglobal.com/campaign/create';

        const formData = new FormData();
        formData.append(
            'request',
            JSON.stringify({
                auth: { usuario: 'SmartIVR', clave: 'MmEwY2Q5' },
                datosCampania: {
                    nombre: 'PruebaTESTAPI',
                    fechaDesde: fecha_desde,
                    fechaHasta: fecha_hasta,
                    horarios: [
                        { dia: 'Lunes', desde: '00:10', hasta: '23:50' },
                        { dia: 'Martes', desde: '00:10', hasta: '23:50' },
                        { dia: 'Miercoles', desde: '00:10', hasta: '23:50' },
                        { dia: 'Jueves', desde: '00:10', hasta: '23:50' },
                        { dia: 'Viernes', desde: '00:10', hasta: '23:50' },
                        { dia: 'Sabado', desde: '00:10', hasta: '23:50' },
                        { dia: 'Domingo', desde: '00:10', hasta: '23:50' }
                    ],
                    numero: 'TramaCelular',
                    tipo: 'audio'
                }
            })
        );

        const audioFile = new File([audio], 'audio_pcm_16bit_mono_8khz.wav', { type: 'audio/wav' });
        console.log('AudioFile CREADO NUEVO: ', audioFile);

        const lote = 'Telefono;Nombre\n' + numberToTest + ';John\n'
        const loteFile = new File([lote], 'audiencia.csv', { type: 'text/csv' });

        formData.append('audio', audioFile);   //this is what's working
        formData.append('lote', loteFile);

        fetch(url, {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            console.log('Audio de prueba enviado correctamente: ', data);
        })
        .catch(error => {
            console.error('Hubo problemas con el audio de prueba: ', error);
        });

    }

    // async sendTestMessageToSondeos(audio, numberToTest) {
    //     console.log("in sendTestMessage2.......");

    //     let fecha_hoy = new Date();
    //     let day = `0${fecha_hoy.getDate()}`.slice(-2);
    //     let month = `0${fecha_hoy.getMonth() + 1}`.slice(-2);
    //     let year = fecha_hoy.getFullYear();

    //     let fecha_desde = `${day}-${month}-${year}`;
    //     let fecha_hasta = `${day}-${month}-${year}`;

    //     let url = 'https://cmpapi.sondeosglobal.com/campaign/create';

    //     const formData = new FormData();
    //     formData.append(
    //         'request',
    //         JSON.stringify({
    //             auth: { usuario: 'SmartIVR', clave: 'MmEwY2Q5' },
    //             datosCampania: {
    //                 nombre: 'PruebaTESTAPI',
    //                 fechaDesde: fecha_desde,
    //                 fechaHasta: fecha_hasta,
    //                 horarios: [
    //                     { dia: 'Lunes', desde: '00:10', hasta: '23:50' },
    //                     { dia: 'Martes', desde: '00:10', hasta: '23:50' },
    //                     { dia: 'Miercoles', desde: '00:10', hasta: '23:50' },
    //                     { dia: 'Jueves', desde: '00:10', hasta: '23:50' },
    //                     { dia: 'Viernes', desde: '00:10', hasta: '23:50' },
    //                     { dia: 'Sabado', desde: '00:10', hasta: '23:50' },
    //                     { dia: 'Domingo', desde: '00:10', hasta: '23:50' }
    //                 ],
    //                 numero: 'TramaCelular',
    //                 tipo: 'audio'
    //             }
    //         })
    //     );

    //     console.log("now atob...........");
    //     const audio = atob(this.versiondataString);
        
    //     console.log("audio length = ", audio.length);
    //     console.log("atob(this.contect_data).length = ", atob(this.versiondataString).length);

    //     let ab = Uint8Array.from(audio, x => x.charCodeAt(0));
    //     console.log("typeof ab = ", typeof ab);
    //     console.log("length of ab = ", ab.byteLength);

    //     const audioFile = new File([ab], 'audio_pcm_16bit_mono_8khz.wav', { type: 'audio/wav' });
    //     console.log('AudioFile CREADO NUEVO: ', audioFile);

    //     const lote = 'Telefono;Nombre\n' + numberToTest + ';John\n'
    //     const loteFile = new File([lote], 'audiencia.csv', { type: 'text/csv' });

    //     formData.append('audio', audioFile);   //this is what's working
    //     formData.append('lote', loteFile);

    //     fetch(url, {
    //         method: 'POST',
    //         body: formData
    //     })
    //     .then(response => response.json())
    //     .then(data => {
    //         console.log('Audio de prueba enviado correctamente: ', data);
    //     })
    //     .catch(error => {
    //         console.error('Hubo problemas con el audio de prueba: ', error);
    //     });

    // }





    @wire(MessageContext)
    messageContext;

    async handleEnviar() {

        if (!this.ContentVersionId)
            return;

        const result = await prosumerEnviarCampaña.open({
            size: 'small',
            cantidadMensajes: this.formatedValues.number_of_mobiles,
            costoPrueba: this.formatedValues.campaign_cost
        });

        if (!result) return;

        const totalOfMobiles = this.valuesFromAudiencePage.number_of_mobiles;

        const haveCredits = await consumeCredits({ totalOfMobiles: totalOfMobiles });

        if (!haveCredits) return;

        const payload = { refreshCredits: true };
        publish(this.messageContext, prosumerMessageChannel, payload);

        // ************************************************
        // Calculates the actual COST of the campaign
        // ************************************************
        let costo = 0;
        if (this.valuesFromAudiencePage.type_of_campaign == 'ivrCampaignMobile') {
            costo = this.accountCreditInformation.ivr_cost * this.valuesFromAudiencePage.number_of_mobiles;
        }
        if (this.valuesFromAudiencePage.type_of_campaign == 'ivrCampaignFijo') {
            costo = this.accountCreditInformation.ivr_cost * this.valuesFromAudiencePage.number_of_fijos;
        }
        
        // ************************************************
        // Change SAQL base on type of phone selected
        // ************************************************
        let saql = "";
        if (this.valuesFromAudiencePage.type_of_campaign == 'ivrCampaignFijo') {
            saql = this.valuesFromAudiencePage.homePhoneQuery_forMc.query;
        }
        if (this.valuesFromAudiencePage.type_of_campaign == 'ivrCampaignMobile') {
            saql = this.valuesFromAudiencePage.mobilePhoneQuery_forMc.query;
        }

        // ************************************************
        // Creates the Campaign Record
        // ************************************************
        const createCampaingIVRParams = {
            titulo: this.tituloCampania,
            saql: saql,
            filtros: JSON.stringify(this.valuesFromAudiencePage.filters),
            audiofileid: this.ContentVersionId,
            costo: costo,
            moviles: this.valuesFromAudiencePage.number_of_mobiles,
            personas: this.valuesFromAudiencePage.number_of_people,
            fecha_inicio: this.fecha_inicio,
            fecha_finalizacion: this.fecha_finalizacion,
            hora_inicio: this.hora_inicio,
            hora_finalizacion: this.hora_finalizacion
        }
        console.log(createCampaingIVRParams);

        let campaignId = await createCampaignIVR(createCampaingIVRParams)
            .catch(error => { console.log('Error al crear la campaña: ' + JSON.stringify(error)); });

        if (!campaignId) { return }

        // ************************************************
        // Creates the Export Record
        // ************************************************
        let data = await insertExportToSondeosIVR({ campaignId: campaignId })
            .catch(error => { console.log('Error al crear la campaña: ' + JSON.stringify(error)); });

        console.log(`data = ${data}`);
        console.log(JSON.stringify(data));


        if (!data) { return }
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

    updateFechaInicio(event) {
        console.log("updateFechaInicio 09");
        console.log(event.target.value);
        this.fecha_inicio_input = event.target.value;
        this.fecha_inicio = this.parseDateFromInput(event.target.value);
        console.log(this.fecha_inicio);
        console.log(this.fecha_inicio_input);
    }

    updateFechaFinalizacion(event) {
        console.log(event.target.value);
        this.fecha_finalizacion_input = event.target.value;
        this.fecha_finalizacion = this.parseDateFromInput(event.target.value);
        console.log(this.fecha_finalizacion);
        console.log(this.fecha_finalizacion_input);
    }

    parseDateFromInput(fecha) {
        let date_parts = fecha.split("-");
        let year = parseInt(date_parts[0]);
        let month = parseInt(date_parts[1]) - 1;
        let day = parseInt(date_parts[2]);
        return new Date(year, month, day);
    }

    handleSliderChange(event) {
        console.log("handleSliderChange 001");
        this.hora_inicio = `00${event.detail.start}:00`.slice(-5);
        this.hora_finalizacion = `00${event.detail.end}:00`.slice(-5);
        console.log(this.hora_inicio);
        console.log(this.hora_finalizacion);
    }

    fileSrc = '';
    ContentVersionId;
    fileInMemory;

    async handleGestorArchivos() {
        const result = await prosumerFileInput.open({
            size: 'large',
            label: 'Modal Seleccionar Accion',
            filestypes: ['.wav']
        });
        if (!result) return;

        //luego de guardar, pongo el preview
        this.fileSrc = result.contentDownloadUrl;
        this.ContentVersionId = result.contentVersionId;
        this.fileInMemory = result.fileInMemory;
        console.log("in handleGestorArchivos .... this.fileInMemory = ", this.fileInMemory);

        if(!result.fileInMemory){
            this.versiondataString = await getContentVersionDataAsString({ContentVersionId:result.contentVersionId});
            console.log('this.versiondataString? ', this.versiondataString);
            console.log('typeof this.versiondataString? ', typeof this.versiondataString);
            console.log('length this.versiondataString? ', this.versiondataString.length);
            console.log('length this.versiondataString? ', atob(this.versiondataString).length);
        }
    }

    get mobile_selected() {
        return this.valuesFromAudiencePage.type_of_campaign == 'ivrCampaignMobile';
    }

    get fijo_selected() {
        return this.valuesFromAudiencePage.type_of_campaign == 'ivrCampaignFijo';
    }

}