import { LightningElement, api, track } from 'lwc';
import Resources from '@salesforce/resourceUrl/PRM';

export default class TerritoryDetailCardType1 extends LightningElement {
    @api icon;
    @api value;
    @api name;
    @api description;
    @api community;
    @track icono;

    renderedCallback() { 
        this.iconBase = Resources + '/' + this.community;
        this.icono = this.iconBase + this.icon.slice(this.icon.indexOf('/img/'));
        // console.log('icon 2: ' + this.icono);
    }
}