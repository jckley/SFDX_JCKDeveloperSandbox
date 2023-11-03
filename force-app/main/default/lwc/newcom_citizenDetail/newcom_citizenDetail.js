import { LightningElement,api,track,wire } from 'lwc';
import retrieveLoggedUserPermissions from '@salesforce/apex/ContactDetailController.retrieveLoggedUserPermissions';
import retrieveInfoFromCitizenId from '@salesforce/apex/CommunitiesController.retrieveInfoFromCitizenId';
import retrieveSite from '@salesforce/apex/CommunitiesController.retrieveSite';
import { loadStyle } from 'lightning/platformResourceLoader';
import RESOURCES from '@salesforce/resourceUrl/Communities';
import { handlePRMCommunityEvent } from 'c/pubsub';

export default class Communities_CitizenDetail extends LightningElement {

    @api recordId;
    @track record;
    @track permissions;
    @track error;
    @track communitySite;
    @track contactName;
    @track viewCommonData;
    @track edit;
    @track viewContactInfo;
    @track viewContactLocation;
    @track viewContactAttributes;
    @track viewContactTags;
    @track attributes = [];
    @track viewContactIncome;
    @track employers = [];
    @track viewContactElectoral;

    //recordId = '0033B00000Vyf7bQAB';

    @wire(retrieveSite)
    wiredSite({ error, data }) {
        if (data) {
            //console.log(JSON.stringify(data));
            this.communitySite = data;
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
        // loadStyle(this, RESOURCES + '/' + this.communitySite + '/css/communities_citizenDetail.css')
        //     /**
        //     .then(result => {
        //         // Possibly do something when load is complete.
        //     })
        //      */
        //     .catch(reason => {
        //         console.log('Error en carga de CSS:' + reason);
        //     });
    }

    @wire(retrieveInfoFromCitizenId, { contactId: '$recordId' })
    wiredContact({ error, data }) {
        if (data) {
            //console.log(JSON.stringify(data));
            this.record = data;
            this.error = undefined;
            this.doLoadContactData();
            console.log("Receiving citizen...");
        } else if (error) {
            console.error(error);
            console.error('error.name => ' + error.name );
            console.error('error.message => ' + error.message );
            console.error('error.stack => ' + error.stack );
            this.error = error;
            this.record = undefined;
        }
    }

    connectedCallback() {
        console.log('Communities_CitizenDetail In connectedCallback()...');
        
        retrieveLoggedUserPermissions()
            .then(result => {
                this.permissions = result;
                this.error = undefined;
                this.doLoadPermissions();
            })
            .catch(error => {
                this.error = error;
                this.permissions = undefined;
            });
        
        document.querySelector(".search-bar-container").style.display = "";
        document.querySelector("#header-extension").style.display = "";
        document.querySelector("#parent-div-search-super-m").style.display = "";
    }

    doLoadContactData(){
        this.contactName = this.record.citizen.Name;
        this.attributes = this.record.attributes.items;
        this.employers = this.record.incomeInfo.employers;
    }
    
    doLoadPermissions(){
        this.viewCommonData = this.permissions.ContactViewCommonData;
        this.edit = this.permissions.ViewEdition;
        this.viewContactInfo = this.permissions.ContactViewContactInfo;
        this.viewContactLocation = this.permissions.ContactViewLocation;
        this.viewContactAtrributes = this.permissions.ContactViewAttributes;
        this.viewContactIncome = this.permissions.ContactViewIncome;
        this.viewContactElectoral = this.permissions.ContactViewElectoral;
        this.viewContactTags = this.permissions.ContactViewTags;
    }
    
    get showAttributes(){
        // var i;
        // for(i = 0; i < this.attributes.length; i++){
        //     console.log('attributes in CD:' +  this.attributes[i].label);
        //     console.log('attributes in CD:' +  this.attributes[i].value);
        // }
        // console.log('viewContactAtrributes in CD:' +  this.viewContactAtrributes);
        try{
            this.doLoadContactData();
            this.doLoadPermissions();
        } catch (e){
            console.log('error en show atributes: ' + e);
        }
        return this.attributes.lenght > 0 && this.viewContactAtrributes;
    }

    get showIncome(){
        //console.log('employers:' +  this.employers);
        //console.log('viewContactIncome:' +  this.viewContactIncome);
        try{
            this.doLoadContactData();
            this.doLoadPermissions();
        } catch (e){
            console.log('error en show income: ' + e);
        }
        return this.employers.lenght > 0 && this.viewContactIncome;
    }
}