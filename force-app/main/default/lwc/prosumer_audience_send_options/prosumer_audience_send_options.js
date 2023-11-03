import { LightningElement, api, track } from 'lwc';

export default class Prosumer_audience_send_options extends LightningElement {
    @api total_number_of_credits;
    
    @track number_of_people = 900456;
    @track number_of_mobiles = 810601;
    @track number_of_phones = 890751;
    @track number_of_emails = 431249;

    @track sms_cost = -35;
    @track ivr_cost = -350;
    @track email_cost = -30;

    @track has_sms_credits = true;
    @track has_ivr_credits = false;
    @track has_email_credits = false;
}