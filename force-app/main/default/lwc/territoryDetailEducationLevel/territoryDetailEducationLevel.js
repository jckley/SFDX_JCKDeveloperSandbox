import { LightningElement, api } from 'lwc';

export default class TerritoryDetailEducationLevel extends LightningElement {
    @api icon;
    @api value;
    @api name;
    @api description;

    renderedCallback() { 
    }
}