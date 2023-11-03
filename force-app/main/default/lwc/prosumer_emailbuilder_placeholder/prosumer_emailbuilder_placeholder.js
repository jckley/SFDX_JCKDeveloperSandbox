import { LightningElement, api } from 'lwc';

export default class Prosumer_emailbuilder_placeholder extends LightningElement {
    _placeholderobject

    @api
    set placeholderobject(value) {
        this._placeholderobject = value;
        if (this.firstRender) {
            //luego del first render, el nodo ya tiene info, asi que si voy a meterle "cosas nuevas", hay que limpiar lo existente.,
            while (this.mainNode.firstChild) {
                this.mainNode.removeChild(this.mainNode.firstChild);
            }
            this.mainNode.appendChild(value.getHtmlElemnt());
        }
    }
    get placeholderobject() {
        return this._placeholderobject;
    }

    get cssClasses() {
        return this.placeholderobject.imSelected ? 'prSelected' : 'prNoSelected';
    }

    _mainNode;

    get mainNode() {
        if (!this._mainNode) {
            this._mainNode = this.template.querySelector("[data-placeholder]");
        }

        return this._mainNode;
    }

    firstRender = false;
    renderedCallback() {
        if (!this.firstRender) {
            this.firstRender = true;
            this.mainNode.appendChild(this.placeholderobject.getHtmlElemnt());
        }
    }

    handleClick() {
        const previewclick = new CustomEvent('previewclick', { detail: { objectKey: this.placeholderobject.key } });
        this.dispatchEvent(previewclick);
    }

    handleDeleteClick() {
        const deleteclick = new CustomEvent('deleteclick', { detail: { objectKey: this.placeholderobject.key } });
        this.dispatchEvent(deleteclick);
    }

}