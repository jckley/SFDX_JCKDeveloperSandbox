import { LightningElement,api,track,wire } from 'lwc';
import RESOURCES from '@salesforce/resourceUrl/Communities';
import { loadStyle } from 'lightning/platformResourceLoader';
import retrieveSite from '@salesforce/apex/CommunitiesController.retrieveSite';
import Employer from '@salesforce/label/c.Employer';
import CUIT from '@salesforce/label/c.CUIT';
import Income from '@salesforce/label/c.Income';

export default class Communities_contactEmployer extends LightningElement {

    @track community_site;
    @track error;
    @api employer;
    @api cuit;
    @api income;

    label = {
        Employer,
        CUIT,
        Income,
    };

    @wire(retrieveSite)
    wiredSite({ error, data }) {
        if (data) {
            //console.log(JSON.stringify(data));
            this.community_site = data;
            this.error = undefined;
            this.doLoadStyles();
            this.iconProfile = RESOURCES + '/' + this.community_site + '/img/profile.svg';
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
        // loadStyle(this, RESOURCES + '/' + this.community_site + '/css/communities_contactEmployer.css')
        //     /**
        //     .then(result => {
        //         // Possibly do something when load is complete.
        //     })
        //      */
        //     .catch(reason => {
        //         console.log('Error en carga de CSS:' + reason);
        //     });
    }

    
}