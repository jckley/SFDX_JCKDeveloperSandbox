import { LightningElement,api,track,wire } from 'lwc';
import RESOURCES from '@salesforce/resourceUrl/Communities';
import { loadStyle } from 'lightning/platformResourceLoader';
import retrieveSite from '@salesforce/apex/CommunitiesController.retrieveSite';
import retrieveInfoFromCitizenId from '@salesforce/apex/CommunitiesController.retrieveInfoFromCitizenId';
import Electoral from '@salesforce/label/c.Electoral';
import District from '@salesforce/label/c.District';
import Section from '@salesforce/label/c.Section';
import Circuit from '@salesforce/label/c.Circuit';
import ElectoralSchool from '@salesforce/label/c.ElectoralSchool';
import ElectoralBooth from '@salesforce/label/c.ElectoralBooth';
import Yes from '@salesforce/label/c.Yes';
import No from '@salesforce/label/c.No';

export default class Communities_contactAttributesElectoral extends LightningElement {

    @api recordId;
    @track record;
    @track community_site;
    @track error;
    @track iconCheck;
    @track district;
    @track districtName;
    @track section;
    @track sectionName;
    @track circuit;
    @track electoralSchool;
    @track electoralBooth;
    @track paso15;
    @track general15;
    @track ballotage15;
    @track paso17;
    @track general17;
    @track paso19;
    @track general19;
    @track affiliation;

    label = {
        Electoral,
        District,
        Section,
        Circuit,
        ElectoralSchool,
        ElectoralBooth,
        Yes,
        No,
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
            this.iconCheck = RESOURCES + '/' + this.community_site + '/img/check.svg';
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
        // loadStyle(this, RESOURCES + '/' + this.community_site + '/css/communities_contactAttributesElectoral.css')
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
        this.district = this.record.citizen.Electoral_District__c;
        this.districtName = this.record.citizen.Electoral_District_name__c;
        this.section = this.record.citizen.Electoral_Section__c;
        this.sectionName = this.record.citizen.Electoral_Section_name__c;
        this.circuit = this.record.citizen.Electoral_Circuit__c;
        this.electoralSchool = this.record.citizen.Escuela_Electoral__c;
        this.electoralBooth = this.record.citizen.Electoral_Booth__c;

        this.paso15 = this.record.citizen.voting_P2015__c === 'EMITIDO' ? this.label.Yes : this.label.No;
        this.general15 = this.record.citizen.voting_G2015__c === 'EMITIDO' ? this.label.Yes : this.label.No;
        this.ballotage15 = this.record.citizen.voting_B2015__c === 'EMITIDO' ? this.label.Yes : this.label.No;
        this.paso17 = this.record.citizen.voting_P2017__c === 'EMITIDO' ? this.label.Yes : this.label.No;
        this.general17 = this.record.citizen.voting_G2017__c === 'EMITIDO' ? this.label.Yes : this.label.No;
        this.paso19 = this.record.citizen.voting_P2019__c === 'EMITIDO' ? this.label.Yes : this.label.No;
        this.general19 = this.record.citizen.voting_G2019__c === 'EMITIDO' ? this.label.Yes : this.label.No;

        this.affiliation = this.record.citizen.party_affiliation__c;
    }

}