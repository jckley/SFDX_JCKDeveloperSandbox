import { LightningElement, api } from 'lwc';

export default class Section_empatia extends LightningElement {
    @api get empatiaRecord () {
        return this._empatiaRecord;
    }

    set empatiaRecord (value) {
        this._empatiaRecord = value;
        //el proxi permite setear los valores default de cualquier propiedad indefinida. La logica esta en el handler.
        if(value) this.proxyRecord = new Proxy(this.empatiaRecord, this.handler);
    }

    proxyRecord;

    handler = {
        get: function (target, name) {
            return target.hasOwnProperty(name) ? target[name] : '–'
        }
    }

    get participaciones () {
        if(!this.empatiaRecord?.Participacion__c) return null;
        console.log('participacion: ', this.empatiaRecord.Participacion__c);
        let participacionesArray = this.empatiaRecord.Participacion__c.split(";");
        console.log('participacionesArray: ', participacionesArray);
        return participacionesArray;
    }

    get fechaNormalizada () {
        const options = {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric',
        };

        console.log('que trae esto aca: ', typeof(this.empatiaRecord.Empatia_Activista__r.Fecha_de_Inscripcion__c))
        let dateObject = new Date(this.empatiaRecord.Empatia_Activista__r.Fecha_de_Inscripcion__c);
          
        return dateObject.toLocaleDateString('es-AR', options)
    }

}