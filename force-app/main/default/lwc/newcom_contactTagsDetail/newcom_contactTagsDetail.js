import { LightningElement,api } from 'lwc';

export default class Newcom_contactTagsDetail extends LightningElement {
    @api recordId;
    @api value;

    get newValue(){
        return '#' + this.value;
    }

}