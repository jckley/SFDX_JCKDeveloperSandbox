import { LightningElement,api,track,wire } from 'lwc';
import Yes from '@salesforce/label/c.Yes';
import No from '@salesforce/label/c.No';
import Email from '@salesforce/label/c.Email';
import Cellphone from '@salesforce/label/c.Cellphone';
import RESOURCES from '@salesforce/resourceUrl/Communities';
import retrieveSite from '@salesforce/apex/CommunitiesController.retrieveSite';
import { loadStyle } from 'lightning/platformResourceLoader';
import retrieveInfoFromCitizenId from '@salesforce/apex/CommunitiesController.retrieveInfoFromCitizenId';

export default class Communities_contactContactInfo extends LightningElement {

    @api recordId;
    @track record;
    @track community_site;
    @track emailIcon;
    @track cellphoneIcon;

    label = {
        Yes,
        No,
        Email,
        Cellphone
    };

    @wire(retrieveInfoFromCitizenId, { contactId: '$recordId' })
    wiredContact({ error, data }) {
        if (data) {
            //console.log(JSON.stringify(data));
            this.record = data;
            this.error = undefined;
        } else if (error) {
            console.error(error);
            console.error('error.name => ' + error.name );
            console.error('error.message => ' + error.message );
            console.error('error.stack => ' + error.stack );
            this.error = error;
            this.record = undefined;
        }
    }

    @wire(retrieveSite)
    wiredSite({ error, data }) {
        if (data) {
            //console.log(JSON.stringify(data));
            this.community_site = data;
            this.error = undefined;
            this.doLoadStyles();
            // this.emailIcon = RESOURCES + '/' + this.community_site + '/img/mail.svg';
            this.emailIcon = RESOURCES + '/' + this.community_site + '/img/dark-mail.png';
            // this.cellphoneIcon = RESOURCES + '/' + this.community_site + '/img/cel.svg';
            this.cellphoneIcon = RESOURCES + '/' + this.community_site + '/img/dark-cel.png';
        } else if (error) {
            console.error(error);
            console.error('error.name => ' + error.name );
            console.error('error.message => ' + error.message );
            console.error('error.stack => ' + error.stack );
            this.error = error;
            this.community_site = undefined;
        }
    }

    doLoadStyles(){
        // loadStyle(this, RESOURCES + '/' + this.community_site + '/css/communities_contactContactInfo.css')
        //     /**
        //     .then(result => {
        //         // Possibly do something when load is complete.
        //     })
        //      */
        //     .catch(reason => {
        //         console.log('Error en carga de CSS:' + reason);
        //     });
    }

    get email(){
        try{
            return this.record.pilar360.email ? this.record.pilar360.email : this.label.No;
        } catch(e){
            return this.label.No;
        }
    }

    get cellphone(){
        try{
            return this.record.pilar360.mobile_phone ? this.record.pilar360.mobile_phone : this.label.No;
        } catch(e){
            return this.label.No;
        }
    }

    
}