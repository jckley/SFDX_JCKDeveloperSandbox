import { LightningElement, api } from 'lwc';

export default class Section_comunidad_river extends LightningElement {
    _riverData

    @api set riverData(value) {
        console.log('value en comunidad river: ', value)
        if(value && value.length > 0) {
            const temp = value[0];
            console.log('seteo riverData')
            this._riverData = {
                ...temp,
                voto_2009__c: temp.voto_2009__c ? 'SI' : 'NO',
                voto_2013__c: temp.voto_2013__c ? 'SI' : 'NO',
                voto_2017__c: temp.voto_2017__c ? 'SI' : 'NO',
                voto_2021__c: temp.voto_2021__c ? 'SI' : 'NO'
            };
        }
    }

    get riverData() {
        return this._riverData
    }
}