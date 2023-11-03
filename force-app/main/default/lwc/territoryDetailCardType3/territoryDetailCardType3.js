import { LightningElement, api } from 'lwc';

export default class TerritoryDetailCardType3 extends LightningElement {
    @api icon;
    @api value;
    @api name;
    @api description;
    @api community;
    @api link;
    @api haslink;

    renderedCallback() { 
    }
}