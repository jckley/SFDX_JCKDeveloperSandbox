import { LightningElement, api } from 'lwc';
import { getHtmlAsText, componentBuilder } from './componentBuilder/componentBuilder.js';
import getEmailRecord from '@salesforce/apex/prosumer_email_controller.getEmailRecord';
import updateEmailRecord from '@salesforce/apex/prosumer_email_controller.updateEmailRecord';
import createEmailRecord from '@salesforce/apex/prosumer_email_controller.createEmailRecord';

import enviarPrueba from '@salesforce/apex/Prueba.enviarPrueba';
import getDominios from '@salesforce/apex/prosumer_gestor_dominiosController.getDominios';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Prosumer_emailbuilder extends LightningElement {

    //para evitar problemas con el framework, listOfComponents se usa para renderizar cosas
    //y se renueva luego de cada cambio en componentBuilder con una copia de los datos alli guardados 
    //componentBuilder, ademas de los datos, guarda logica para hacer diferentes operaciones: mutar un elemento, reemplazarlo, inicializar el array, etc
    listOfComponents = [];
    @api emailid;

    idOfNewCreatedEmail;
    _listDominios;

    connectedCallback() {
        getDominios()
            .then(response => {
                this._listDominios = response;
            })
            .catch(error => {
                console.log('Paso algo en prosumer_gestor_dominiosController getDominios: ', error);
            })

        if (this.emailid) {
            getEmailRecord({ emailid: this.emailid })
                .then(emailRecord => {
                    const emailObject = JSON.parse(emailRecord.Email_JSON__c);
                    this.nombreDelMail = emailObject.nombreDelMail;
                    //la informacion sobre como regenerar el email se va a guardar en emailRecord.Email_JSON__c
                    componentBuilder.buildFromArray(emailObject.listOfComponents);
                    this.listOfComponents = componentBuilder.getHtmlElemntsArray();
                })
                .catch(error => {
                    console.log('Ocurrio un error al recuperar el mail: ', error)
                });
        } else {
            componentBuilder.buildPlaceHoldersArray();
            this.listOfComponents = componentBuilder.getHtmlElemntsArray();
        }
    }

    //de aca deberia extrar logica a una funcion, algo combinado estos otros...
    handleTemplateClick(event) {
        const selectedType = event.detail.typekey;
        const newKey = componentBuilder.replaceElementSelected(selectedType);
        componentBuilder.changePropertyToElementByKey(newKey, { imSelected: true });
        this.listOfComponents = componentBuilder.getHtmlElemntsArray();
    }

    async handleEnviarPrueba() {
        const prosumer_toast = this.template.querySelector('c-prosumer-toast');
        
        const stringParaPrueba = obtenerStringFormateadoParaHTMLEmail(componentBuilder.getHtmlElemntsArray());
        const mailDestinatarioParaPrueba = this.mailDestinatario;
        const mailRemitenteParaPrueba = this.nombreMailRemitente + this.dominioMailRemitente;
        const nombreRemitenteParaPrueba = this.nombreRemitente;

        try {
            let resultadoDelEnvio = await enviarPrueba({'emailAddress': mailDestinatarioParaPrueba,
                                                'fromEmail': mailRemitenteParaPrueba,
                                                'fromName': nombreRemitenteParaPrueba,
                                                'htmlEmail': stringParaPrueba});




            if(resultadoDelEnvio){
                const evt = new ShowToastEvent({
                    title: 'El mail de prueba se envio correctamente',
                    message: `Se envio el mail a ${mailDestinatarioParaPrueba} desde la siguiente casilla ${mailRemitenteParaPrueba} con el alias ${nombreRemitenteParaPrueba}. Recuerde chequear spam!`,
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                prosumer_toast.showConfirmation('Email de prueba enviado satisfactoriamente.');
            }

        } catch (error) {
            prosumer_toast.showAlerta('Ocurrió un error durante el envío de email de prueba.');
        }
    }

    handleGuardar () {

        const htmlString = obtenerStringFormateadoParaHTMLEmail(componentBuilder.getHtmlElemntsArray());

        const tempObject = {
            nombreDelMail: this.nombreDelMail,
            listOfComponents: this.listOfComponents
        }
        const jsonObject = JSON.stringify(tempObject);
        if (this.emailid || this.idOfNewCreatedEmail){
            const idOfTheEmailToUpdate = this.emailid || this.idOfNewCreatedEmail;
            updateEmailRecord({emailid : idOfTheEmailToUpdate, htmlString, jsonObject})
                .then(updatedRecordObject => {
                    const evt = new ShowToastEvent({
                        title: 'Se actualizo el registro correctamente',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                });
        } else {
            createEmailRecord({htmlString, jsonObject})
                .then(createdRecordId => {
                    this.idOfNewCreatedEmail = createdRecordId;
                    const evt = new ShowToastEvent({
                        title: 'Se creo el registro correctamente',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                });
        }
    }

    //de aca deberia extrar logica a una funcion, algo combinado estos otros...
    handlePreviewClick(event) {
        //change the selected one
        const clickedObjectKey = event.detail.objectKey;
        componentBuilder.changePropertyToAll({ imSelected: false });
        componentBuilder.changePropertyToElementByKey(clickedObjectKey, { imSelected: true });
        this.listOfComponents = componentBuilder.getHtmlElemntsArray();
    }

    //de aca deberia extrar logica a una funcion, algo combinado estos otros...
    handleDeleteClick(event) {
        const clickedObjectKey = event.detail.objectKey;
        componentBuilder.changePropertyToAll({ imSelected: false });
        const newElementKey = componentBuilder.replaceElementByKey(clickedObjectKey, 'place holder');
        componentBuilder.changePropertyToElementByKey(newElementKey, { imSelected: true });
        this.listOfComponents = componentBuilder.getHtmlElemntsArray();
    }

    handleChangeProperty(event) {
        //mismo caso que el anterior, reemplazo array y objetos para triggerar el rerender.
        const selectedObjectType = componentBuilder.getSelectedType();
        const tempObject = {};

        if (selectedObjectType === 'texto') {
            tempObject.contenidoDelTexto = event.detail.textValue
        }
        if (selectedObjectType === 'imagen') {
            tempObject.imageSrc = event.detail.imgSrc
        }
        if (selectedObjectType === 'boton') {
            tempObject.etiquetaBoton = event.detail.buttonLabel
            tempObject.urlBoton = event.detail.buttonUrl;
        }

        componentBuilder.changePropertyToElementIfSelected(tempObject);

        this.listOfComponents = componentBuilder.getHtmlElemntsArray();
    }

    nombreDelMail;
    handleNombreChange (event) {
        this.nombreDelMail = event.detail.value;
    }

    mailDestinatario;
    handleMailDestinatarioChange (event) {
        this.mailDestinatario = event.detail.value;
    }

    nombreMailRemitente;
    handleNombreMailRemitenteChange(event){
        this.nombreMailRemitente = event.detail.value;
    }
    dominioMailRemitente;
    handleDominioMailRemitenteChange(event){
        this.dominioMailRemitente = event.detail.value;
    }

    nombreRemitente;
    handleNombreRemitenteChange(event){
        this.nombreRemitente = event.detail.value;
    }

    get opcionesDominios() {
        if(!this._listDominios){
            return []
        }

        const tempArray = this._listDominios.filter(thisDominio=>thisDominio.Dominio_Verificado__c).map(thisDominio=>{
            return {
                label:thisDominio.Name,
                value:thisDominio.Name
            }
        })

        return tempArray;
    }

}

function obtenerStringFormateadoParaHTMLEmail (arrayDeElementosHtml) {
    const htmlArray = arrayDeElementosHtml.map(thisElement => {
        if (thisElement.type !== 'place holder') {
            return getHtmlAsText(thisElement.getHtmlElemnt());
        }
        return '';
    })

    //hasta no buscar bien como funca esto, es lo mismo enviar el html el suelto que envuelto en la tabla o el div :/
    return htmlArray.join('');

    //este no anda
    /*
    return `<table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td align="center">
                        ${htmlArray.join('')}
                    </td>
                </tr>
            </table>`
    */

    //este tampoco
    /*
    return `<div style="padding: 15px; display: flex; flex-direction: column; justify-content: center; align-items: center;">
                ${htmlArray.join('')}
            </div>`
    */
}