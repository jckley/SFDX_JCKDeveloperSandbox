import { LightningElement,api,track,wire } from 'lwc';
import RESOURCES from '@salesforce/resourceUrl/Communities';
import ICONS from '@salesforce/resourceUrl/IconsPack1';
import { loadStyle } from 'lightning/platformResourceLoader';
import retrieveSite from '@salesforce/apex/CommunitiesController.retrieveSite';
import retrieveInfoFromCitizenId from '@salesforce/apex/CommunitiesController.retrieveInfoFromCitizenId';

export default class Communities_contactAttributes extends LightningElement {

    @api recordId;
    @track record;
    @track community_site;
    @track error;
    @track attributes;

    @wire(retrieveInfoFromCitizenId, { contactId: '$recordId' })
    wiredContact({ error, data }) {
        if (data) {
            //console.log(JSON.stringify(data));
            this.record = data;
            this.error = undefined;
            this.doLoadContactData();
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
            this.iconAddress = ICONS + '/img/KUhouse_lb.svg';
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
        // loadStyle(this, RESOURCES + '/' + this.community_site + '/css/communities_contactAddress.css')
        //     /**
        //     .then(result => {
        //         // Possibly do something when load is complete.
        //     })
        //      */
        //     .catch(reason => {
        //         console.log('Error en carga de CSS:' + reason);
        //     });
    }

    doLoadContactData(){
        this.attributes = this.record.attributes.items;
        // console.log('attributes in contactAtributes: ' + this.attributes);
    }
}