import { LightningElement,api,wire,track } from 'lwc';
import RESOURCES from '@salesforce/resourceUrl/Communities';
import retrieveSite from '@salesforce/apex/CommunitiesController.retrieveSite';
import { loadStyle } from 'lightning/platformResourceLoader';
import Yes from '@salesforce/label/c.Yes';
import No from '@salesforce/label/c.No';

export default class Communities_contactSocialInfoDetail extends LightningElement {

    @api icon;
    @api name;
    @api socialLink;
    @api socialUser;
    @api showDetails = false;
    @track community_site;

    label = {
        Yes,
        No
    };

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
        // loadStyle(this, RESOURCES + '/' + this.community_site + '/css/communities_contactSocialInfoDetail.css')
        //     /**
        //     .then(result => {
        //         // Possibly do something when load is complete.
        //     })
        //      */
        //     .catch(reason => {
        //         console.log('Error en carga de CSS:' + reason);
        //     });
    }

    get iconUrl(){
        return RESOURCES + '/' + this.community_site + '/img/' + this.icon;
    }

    get hasSocialData(){
        return this.socialLink || this.socialUser ? this.label.Yes : this.label.No;
    }
    
}