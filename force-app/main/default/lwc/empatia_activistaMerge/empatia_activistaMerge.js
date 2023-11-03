import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import changeActivistaInfo from '@salesforce/apex/empatia_activistaMergeController.changeActivistaInfo';
import searchCitizen from '@salesforce/apex/empatia_activistaMergeController.searchCitizen';

import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import DNI_FIELD from '@salesforce/schema/Empatia_Activista__c.DNI__c';
import NACIMIENTO_FIELD from '@salesforce/schema/Empatia_Activista__c.Fecha_de_nacimiento__c';

const FIELDS = [NACIMIENTO_FIELD, DNI_FIELD];


export default class Empatia_activistaMerge extends NavigationMixin(LightningElement) {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    activista;

    get fechaInicial() {
        return getFieldValue(this.activista.data, NACIMIENTO_FIELD)
    }

    get dniInicial() {
        return getFieldValue(this.activista.data, DNI_FIELD)
    }

    lastDniSearch;
    lastFechaSearch;

    confirmationScreen = false;
    infoScreen = true;
    citizenRecord;

    get dniInputValue () {
        const dniInput = this.template.querySelector('.textInput');
        return dniInput.value;
    }

    get fechaInputValue () {
        const fechaInput = this.template.querySelector('.fechaInput');
        return fechaInput.value;
    }

    async handleBuscar() {
        let results;

        const dniValue = this.dniInputValue;
        const fechaValue = this.fechaInputValue;

        try {
            results = await searchCitizen({ dni: dniValue, fecha: fechaValue});
        } catch (error) {
            let message = 'Ocurrio un no gestionado al buscar DNI y fecha de nacimiento. Comuniquese con un administrador.';
            this.showErrorToast(message);
            console.log(error);
            return;
        }

        this.citizenRecord = results;
        this.lastDniSearch = dniValue;
        this.lastFechaSearch = fechaValue;
        this.infoScreen = false;
    }

    valoresParaEditar;

    handleGoToConfirmation() {
        this.valoresParaEditar = {
            dni:this.dniInputValue,
            fecha:this.fechaInputValue
        }
        this.confirmationScreen = true;
    }

    handleCancelar() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    async handleGuardar() {
        let results;

        const dniValue = this.valoresParaEditar.dni;
        const fechaValue = this.valoresParaEditar.fecha;

        try {
            results = await changeActivistaInfo({ recordId: this.recordId, dni: dniValue, fecha: fechaValue});
        } catch (error) {
            let message = error?.body?.message ?? 'Ocurrio un no gestionado al intentar actualizar el activista. Comuniquese con un administrador.';
            this.showErrorToast(message);
            console.log(error);
            this.confirmationScreen = false;
            return;
        }

        let objectResults = JSON.parse(results);

        if (objectResults.operationType === "update") {
            getRecordNotifyChange([{ recordId: this.recordId }]);
            this.dispatchEvent(new CloseActionScreenEvent());
            this.showSuccessToast();
        }

        if (objectResults.operationType === "merge") {

            let pageRef = {
                type: 'standard__recordPage',
                attributes: {
                    recordId: objectResults.activistaId,
                    objectApiName: 'Empatia_Activista__c',
                    actionName: 'view',
                }
            }
            this.showSuccessToast();
            this[NavigationMixin.Navigate](pageRef, true);

        }
    }

    handleGoBackToInput() {
        this.confirmationScreen = false;
    }

    showSuccessToast() {
        const event = new ShowToastEvent({
            title: 'Se realizaron cambios en el activista',
            message:
                'El Activista se modifico satisfactoriamente',
            variant: 'success'
        });
        this.dispatchEvent(event);
    }

    showErrorToast(msj) {
        const event = new ShowToastEvent({
            title: 'Ocurrio un error',
            message: msj,
            variant: 'error'
        });
        this.dispatchEvent(event);
    }
}