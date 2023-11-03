import { LightningElement, api } from 'lwc';

export default class brasil_dashboardSocialSummary extends LightningElement {
    @api total_facebook_formated;
    @api total_instagram_formated;
    @api total_twitter_formated;
    @api total_linkedin_formated;
    @api facebook_icon;
    @api instagram_icon;
    @api twitter_icon;
    @api linkedin_icon;
}