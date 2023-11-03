import { LightningElement,api } from 'lwc';

export default class Empatia_citizen_card extends LightningElement {
    @api param_citizen_record;

    get photoValue() { 
        let record = this.param_citizen_record;
        if (!record) return null;
        if (Boolean(record.PhotoUrl_legacy__c)) return record.PhotoUrl_legacy__c;

        let tempNombre = record.FirstName ?? 'nombre';
        let tempApellido = record.LastName ?? 'apellido';

        let firstNameInitialToCaps = tempNombre ? tempNombre.toUpperCase()[0] : '';
        let lastNameInitialToCaps = tempApellido ? tempApellido.toUpperCase()[0] : '';

        return (firstNameInitialToCaps + lastNameInitialToCaps);
    }

    get citizenHasPhoto () {
        let record = this.param_citizen_record;
        if (!record) return null;
        return Boolean(record.PhotoUrl_legacy__c);
    }

}