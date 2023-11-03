import { LightningElement, wire } from 'lwc';
import getUserCreditInformation from '@salesforce/apex/Prosumer_AudienciaPageController.getUserCreditInformation';

import { NavigationMixin } from 'lightning/navigation';
import PROSUMER_LOGO from '@salesforce/resourceUrl/logopng'

import PROSUMER_LOGOUT from '@salesforce/resourceUrl/prosumerModalAccion';

import prosumerMessageChannel from '@salesforce/messageChannel/prosumer__c';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';

export default class Prosumer_Creditos extends NavigationMixin(LightningElement) {

    

    img = PROSUMER_LOGO;

    logout = PROSUMER_LOGOUT + "/logout.png";


    handleDisconnect(){
        console.log('Disconnecting...');

        //window.location.href = "/s/login";
        
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'logout'
            },
        });
        //console.log('Navigation to Login page completed');
    }

    wired_params;

    get formatedValue() {
        if (!this.wired_params) return { accountCredits: '' };

        return {
            accountCredits: this.wired_params.accountCredits.toLocaleString('es-AR'),
        }
    }

    getCredits() {
        getUserCreditInformation()
            .then(response => {
                this.wired_params = response
            });

    }

    connectedCallback() {
        this.getCredits()
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    subscription = null;

    @wire(MessageContext)
    messageContext;

    // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                prosumerMessageChannel,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    // Handler for message received by component
    handleMessage(message) {
        if (message?.refreshCredits) {
            this.getCredits();
        }
    }

}