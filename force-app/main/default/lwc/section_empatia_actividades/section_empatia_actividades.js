import { LightningElement, api } from 'lwc';

export default class section_empatia_actividades extends LightningElement {
    @api get empatiaRecord () {
        return this._empatiaRecord;
    }

    set empatiaRecord (value) {
        if(!value) return;

        if(value.Empatia_Activista__r){
            this._empatiaRecord = value.Empatia_Activista__r;
        } else {
            this._empatiaRecord = {};
        }
        
        //el proxi permite setear los valores default de cualquier propiedad indefinida. La logica esta en el handler.
        if(value) this.proxyRecord = new Proxy(this.empatiaRecord, this.handler);
    }

    proxyRecord;

    handler = {
        get: function (target, name) {
            return target.hasOwnProperty(name) ? target[name] : '–'
        }
    }

}