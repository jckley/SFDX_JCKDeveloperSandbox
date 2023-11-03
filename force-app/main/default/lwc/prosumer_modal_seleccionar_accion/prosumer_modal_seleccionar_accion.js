import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import getUserCreditInformation from '@salesforce/apex/Prosumer_AudienciaPageController.getUserCreditInformation';

import RESOURCES from '@salesforce/resourceUrl/prosumerModalAccion'


export default class Prosumer_modal_seleccionar_accion extends LightningModal {

    @api input_params;
    wired_params;

    sms = RESOURCES + "/sms.png";
    call = RESOURCES + "/call.png";
    email = RESOURCES + "/email.png";

    nosms = RESOURCES + "/nosms.png";
    nocall = RESOURCES + "/nocall.png";
    noemail = RESOURCES + "/noemail.png";

    logo = RESOURCES + "/logopng.png";

    telefonos_fijos_selected = false;
    telefonos_celulares_selected = false;

    get has_sms_credits() {
        return this.wired_params.accountCredits >= this.wired_params.sms_cost * this.input_params.number_of_mobiles
    }

    get has_ivr_credits() {
        if (this.telefonos_celulares_selected) {
            return this.wired_params.accountCredits >= this.wired_params.ivr_cost * this.input_params.number_of_mobiles;
        }
        if (this.telefonos_fijos_selected) {
            return this.wired_params.accountCredits >= this.wired_params.ivr_cost * this.input_params.number_of_phones
        }
        return false;
    }

    get has_email_credits() {
        //return false;
        return this.wired_params.accountCredits >= this.wired_params.email_cost * this.input_params.number_of_emails
    }

    loading=true;

    connectedCallback() {
        getUserCreditInformation()
            .then(response => {
                this.wired_params = response
                this.loading = false;
            });
    }

    get formatedValues() {
        let ivr_campaing_cost = 0;

        if (this.telefonos_celulares_selected) {
            ivr_campaing_cost = this.wired_params.ivr_cost * this.input_params.number_of_mobiles;
        }

        if (this.telefonos_fijos_selected) {
            ivr_campaing_cost = this.wired_params.ivr_cost * this.input_params.number_of_phones;
        }

        return {
            number_of_people: this.input_params.number_of_people.toLocaleString('es-AR'),
            number_of_mobiles: this.input_params.number_of_mobiles.toLocaleString('es-AR'),
            number_of_phones: this.input_params.number_of_phones.toLocaleString('es-AR'),
            number_of_emails: this.input_params.number_of_emails.toLocaleString('es-AR'),
            sms_campaing_cost: `${(this.wired_params.sms_cost * this.input_params.number_of_mobiles).toLocaleString('es-AR')}`,
            ivr_campaing_cost: `${(ivr_campaing_cost).toLocaleString('es-AR')}`,
            email_campaing_cost: `${(this.wired_params.email_cost * this.input_params.number_of_emails).toLocaleString('es-AR')}`,
        }
    }

    sms_action_selected() {
        this.close('smsCampaing');
    }

    ivr_action_selected() {
        if (this.telefonos_celulares_selected)
            this.close('ivrCampaignMobile');
        if (this.telefonos_fijos_selected)
            this.close('ivrCampaignFijo')
    }

    email_action_selected() {
        this.close('emailCampaign');
    }

    handleTelefonoFijo(event) {
        this.telefonos_fijos_selected = true;
        this.telefonos_celulares_selected = false;
    }

    handleTelefonoCelular(event) {
        this.telefonos_celulares_selected = true;
        this.telefonos_fijos_selected = false;
    }

    get type_of_phone_selected() {
        return this.telefonos_celulares_selected || this.telefonos_fijos_selected;
    }
    
}