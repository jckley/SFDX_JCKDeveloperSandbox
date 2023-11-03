import { LightningElement, api } from 'lwc';

export default class Newcom_dashboardContactSummary extends LightningElement {
    @api total_ciudadanos_formated;
    @api total_emails_formated;
    @api total_mobiles_formated;
    @api total_landing_formated;
}