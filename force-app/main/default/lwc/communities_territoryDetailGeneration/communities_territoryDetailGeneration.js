import { LightningElement, api, track } from 'lwc';
import Resources from '@salesforce/resourceUrl/PRM';

export default class TerritoryDetailGeneration extends LightningElement {
    @api value;
    @api name;
    @api description;
    @api community;
    @api icon;
    @track icono;

    renderedCallback() { 
        this.iconBase = Resources + '/' + this.community;
        this.icono = this.iconBase + this.icon.slice(this.icon.indexOf('/img/'));
        console.log('icon 2: ' + this.icono);
    }
}