import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class Prosumer_modal_simple extends LightningModal {
    @api titulo;
    @api cuerpo;
    @api textoBotonTrue;
    @api textoBotonFalse;
    
    handleBotonFalse(){
        this.close(false)
    }

    handleBotonTrue(){
        this.close(true)
    }
}