import { LightningElement, api } from 'lwc';

export default class TerritoryDetailCardType2 extends LightningElement {
    @api icon;
    @api value;
    @api name;
    @api description;
    @api community;

    renderedCallback() { 
    }
}