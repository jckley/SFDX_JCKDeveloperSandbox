import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import retrieveSite from '@salesforce/apex/CommunitiesController.retrieveSite';
import retrieveInfoFromCitizenId from '@salesforce/apex/CommunitiesController.retrieveInfoFromCitizenId';
import { loadStyle } from 'lightning/platformResourceLoader';
import RESOURCES from '@salesforce/resourceUrl/Communities';
import Level1 from '@salesforce/label/c.Level1';
import Level2 from '@salesforce/label/c.Level2';
import Level3 from '@salesforce/label/c.Level3';
import Level4 from '@salesforce/label/c.Level4';


export default class Communities_contactLocationInfo extends NavigationMixin(LightningElement) {

    @api recordId;
    @track record;
    @track community_site;
    @track error;
    @track pinURL;
    @track level1;
    @track level2;
    @track level3;
    @track level4;
    
    label = {
        Level1,
        Level2,
        Level3,
        Level4
    };

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
            this.pinURL = RESOURCES + '/' + this.community_site + '/img/dark-pin.svg';
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
        // loadStyle(this, RESOURCES + '/' + this.community_site + '/css/communities_contactLocationInfo.css')
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
        this.level1 = this.record.citizen.Level1Name__c;
        this.level2 = this.record.citizen.Level2Name__c;
        this.level3 = this.record.citizen.Level3Name__c;
        this.level4 = this.record.citizen.Level4Name__c;
    }

    viewTerritory1(){
        this.viewTerritory(1);
    }

    viewTerritory2(){
        this.viewTerritory(2);
    }

    viewTerritory3(){
        this.viewTerritory(3);
    }

    viewTerritory4(){
        this.viewTerritory(4);
    }

    viewTerritory(level) {
        let territoryId;
        if(level === 1){
            territoryId = this.record.citizen.Level1ID__c;
        }
        if(level === 2){
            territoryId = this.record.citizen.Level2ID__c;
        }
        if(level === 3){
            territoryId = this.record.citizen.Level3ID__c;
        }
        if(level === 4){
            territoryId = this.record.citizen.Level4ID__c;
        }
        //console.log("territoryId:" + territoryId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: territoryId,
                objectApiName: 'Territorio_Administrativo__c',
                actionName: 'view'
            }
        });
	}
    

}