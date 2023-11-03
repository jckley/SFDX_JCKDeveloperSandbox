import { api} from 'lwc';
import LightningModal from 'lightning/modal';

export default class Prosumer_modal_aceptar_prueba_ivr extends LightningModal {
    @api numeroTelefono;
    @api costoPrueba;

    handleCancelar(){
        this.close()
    }

    handleEnviar(){
        this.close('enviar')
    }
}