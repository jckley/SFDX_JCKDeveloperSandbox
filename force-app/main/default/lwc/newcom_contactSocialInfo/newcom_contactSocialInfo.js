import { LightningElement,api,wire,track } from 'lwc';
import RESOURCES from '@salesforce/resourceUrl/Communities';
import retrieveSite from '@salesforce/apex/CommunitiesController.retrieveSite';
import { loadStyle } from 'lightning/platformResourceLoader';
import retrieveInfoFromCitizenId from '@salesforce/apex/CommunitiesController.retrieveInfoFromCitizenId';

export default class Communities_contactSocialInfo extends LightningElement {

    @api recordId;
    @track record;
    @track community_site;
    @track facebookLink;
    @track facebookUser;
    @track twitterLink;
    @track twitterUser;
    @track instagramLink;
    @track instagramUser;
    @track linkedinLink;
    @track linkedinUser;

    @wire(retrieveInfoFromCitizenId, { contactId: '$recordId' })
    wiredContact({ error, data }) {
        if (data) {
            //console.log(JSON.stringify(data));
            this.record = data;
            this.error = undefined;
            this.loadContactData();
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
        // loadStyle(this, RESOURCES + '/' + this.community_site + '/css/communities_contactSocialInfo.css')
        //     /**
        //     .then(result => {
        //         // Possibly do something when load is complete.
        //     })
        //      */
        //     .catch(reason => {
        //         console.log('Error en carga de CSS:' + reason);
        //     });
    }

    loadContactData(){
        if(this.record.citizen.Facebook_Link__c)
            this.facebookLink = this.record.citizen.Facebook_Link__c;
        if(this.record.citizen.Usuario_Facebook__c)
            this.facebookUser = '/' + this.record.citizen.Usuario_Facebook__c;
        
        if(this.record.citizen.Twitter_Link__c)
            this.twitterLink = this.record.citizen.Twitter_Link__c;
        if(this.record.citizen.Usuario_Twitter__c)
            this.twitterUser = '@' + this.record.citizen.Usuario_Twitter__c;

        if(this.record.citizen.Instagram_Link__c)
            this.instagramLink = this.record.citizen.Instagram_Link__c;
        if(this.record.citizen.Usuario_Instagram__c)
            this.instagramUser = '@' + this.record.citizen.Usuario_Instagram__c;

        if(this.record.citizen.Linkedin_Link__c)
            this.linkedinLink = this.record.citizen.Linkedin_Link__c;
        if(this.record.citizen.Usuario_Linkedin__c)
            this.linkedinUser = '/' + this.record.citizen.Usuario_Linkedin__c;
    }

    get showDetail(){
        return true;
    }

}