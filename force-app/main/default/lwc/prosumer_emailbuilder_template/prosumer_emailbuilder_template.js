import { LightningElement, api } from 'lwc';

export default class Prosumer_emailbuilder_template extends LightningElement {
    @api typename
    @api typekey

    handleClick () {
        const templateClick = new CustomEvent('templateclick', { detail: { typekey:this.typekey } });
        this.dispatchEvent(templateClick);
    }
}