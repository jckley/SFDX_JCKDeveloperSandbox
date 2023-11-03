import { LightningElement, api, track } from 'lwc';
import RESOURCES2 from '@salesforce/resourceUrl/prosumerSendSMS';

export default class ProsumerToast extends LightningElement {

    confirmado = RESOURCES2 + "/confirmado.png";
    
    alerta = RESOURCES2 + "/alert.png";

    mensaje;


    @api showConfirmation(mensaje){
        this.mensaje = mensaje;
        const confirmado = this.template.querySelector('.confirmado');
        confirmado.style.opacity = "1";
        confirmado.style.height = "61px";
        setTimeout(() => {
            this.hideConfirmation();
        }, 4000);
    }

    @api hideConfirmation() {
        mensaje = '';
        const confirmado = this.template.querySelector('.confirmado');
        confirmado.style.opacity = "0";
        confirmado.style.height = "0px";
    }

    @api showAlerta(mensaje){
        this.mensaje = mensaje;
        const confirmado = this.template.querySelector('.alerta');
        confirmado.style.opacity = "1";
        confirmado.style.height = "61px";
        setTimeout(() => {
            this.hideAlerta();
        }, 4000);
    }

    @api hideAlerta() {
        mensaje = '';
        const confirmado = this.template.querySelector('.alerta');
        confirmado.style.opacity = "0";
        confirmado.style.height = "0px";
    }

}