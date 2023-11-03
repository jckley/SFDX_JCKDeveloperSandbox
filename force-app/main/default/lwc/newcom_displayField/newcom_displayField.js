import { LightningElement, api } from 'lwc';
import Yes from '@salesforce/label/c.Yes';
import NoInformation from '@salesforce/label/c.NoInformation';

export default class Communities_DisplayField extends LightningElement {

    @api label;
    @api value;
    @api notShowDetail = false;
    @api emptyValue;
    @api labelCss;
    @api valueCss;

    label = {
        Yes,
        NoInformation
    };

    get cssLabel(){
        return 'slds-col slds-size_1-of-1 ' + this.labelCss;
    }

    get cssValue(){
        return 'slds-col slds-size_1-of-1 ' + this.valueCss;
    }
}