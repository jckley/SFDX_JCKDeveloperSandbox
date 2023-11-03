import { LightningElement, api } from 'lwc';

export default class TerritoryDetailGeneration extends LightningElement {
    @api icon;
    @api value;
    @api name;
    @api description;
    @api community;

    renderedCallback() { 
    }
}