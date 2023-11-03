import { LightningElement, api } from 'lwc';

export default class CommonHeader extends LightningElement {
    @api title;
    @api subtitle;
    @api subtitlelinktext;
    @api subtitlelinkurl;
}