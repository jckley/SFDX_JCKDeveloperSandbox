import { LightningElement, api } from 'lwc';

export default class Section_notas extends LightningElement {
    
    @api notas;

    get formatedNotas () {
        const newNotas = this.notas.map(thisNota=>{
            const objectDate = new Date(thisNota.CreatedDate);
            return {
                ...thisNota,
                CreatedDate:objectDate.toLocaleString()
            }
        })

        return newNotas;
    }

    @api empatiaactivistaid;

    get inputElement () {
        if (! this._inputElement){
            this._inputElement = this.template.querySelector('textarea');
        }
        return this._inputElement;
    }

    handleGuardar () {
        let note_body = this.inputElement.value;
        if (!note_body || note_body === '') return;

        const selectedEvent = new CustomEvent('guardarnota', { detail:{empatiaActivistaId: this.empatiaactivistaid, nota: note_body }});
        this.dispatchEvent(selectedEvent);
        this.inputElement.value = '';
    }
}