import { LightningElement, api } from 'lwc';

export default class Prosumer_emailbuilder_preview extends LightningElement {
    _listofcomponents
    @api
    set listofcomponents(value) {
        this._listofcomponents = value;
        
        if (this.firstRender) {
            while (this.mainNode.firstChild) {
                this.mainNode.removeChild(this.mainNode.firstChild);
            }

            value.forEach(element => {
                if(element.type !== 'place holder'){
                    this.mainNode.appendChild(element.getHtmlElemnt());
                }
                
            });
        }
    }
    get listofcomponents() {
        return this._listofcomponents;
    }

    _mainNode;

    get mainNode() {
        if (!this._mainNode) {
            this._mainNode = this.template.querySelector("[data-placeholder]");
        }

        return this._mainNode;
    }

    //lo que esta pasando es que en el primer ciclo de vida del componente el ornden es el siguiente: @api([{datos}]) ---> render
    //por eso, al momento de la primera carga de info, no hay mainNode
    
    firstRender = false;
    renderedCallback() {
        if (!this.firstRender) {
            this.firstRender = true;
            this.listofcomponents.forEach(element => {
                if(element.type !== 'place holder'){
                    this.mainNode.appendChild(element.getHtmlElemnt());
                }
                
            });
        }
    }
    
}