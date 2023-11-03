import { api} from 'lwc';
import LightningModal from 'lightning/modal';

export default class Prosumer_modal_enviar_campana_sms extends LightningModal {
    @api cantidadMensajes;
    @api costoPrueba;

    handleCancelar(){
        this.close()
    }

    handleEnviar(){
        this.close('enviar')
    }
}