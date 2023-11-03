import { LightningElement,api,track,wire } from 'lwc';
import RESOURCES from '@salesforce/resourceUrl/Communities';
import retrieveLoggedUserPermissions from '@salesforce/apex/ContactDetailController.retrieveLoggedUserPermissions';
import saveCitizenInSalesforce from '@salesforce/apex/ContactDetailController.saveCitizenInSalesforce';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import retrieveSite from '@salesforce/apex/CommunitiesController.retrieveSite';
import retrieveInfoFromCitizenId from '@salesforce/apex/CommunitiesController.retrieveInfoFromCitizenId';

export default class Communities_pageHeader extends NavigationMixin(LightningElement) {

    @api recordId;
    @track record;
    @track mainLabel;
    @track secondaryLabel;
    @track secondaryLabelUnderlined;
    @track community_site;
    @track email;
    @track mobile;
    @track homePhone;
    @track error;
    @track hasHierarchy = false;
    @track permissions;
    @track showModal;
    @track edit = false;

    @wire(retrieveInfoFromCitizenId, { contactId: '$recordId' })
    wiredContact({ error, data }) {
        if (data) {
            //console.log(JSON.stringify(data));
            this.record = data;
            this.error = undefined;
            this.mainLabel = this.record.citizen.Name;
            this.secondaryLabel = this.record.generalInfo.Title;
            this.secondaryLabelUnderlined = this.record.generalInfo.Address;
            this.email = this.record.citizen.Email;
            this.mobile = this.record.citizen.MobilePhone;
            this.homePhone = this.record.citizen.HomePhone;
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

        
    constructor() {
        super();
        console.log('Communities_pageHeader In Constructor...');
        this.email = "";
        this.fijo = "";
        this.mobile = "";
        this.showModal = false;
        //this.record = this.initRecord();
    }

    doLoadStyles(){
        // loadStyle(this, RESOURCES + '/' + this.community_site + '/css/communities_pageHeader.css')
        //     /**
        //     .then(result => {
        //         // Possibly do something when load is complete.
        //     })
        //      */
        //     .catch(reason => {
        //         console.log('Error en carga de CSS:' + reason);
        //     });
    }

    connectedCallback() {
        retrieveLoggedUserPermissions()
            .then(result => {
                this.permissions = result;
                this.error = undefined;
                this.edit = this.permissions.ViewEdition;
                this.rendered = this.permissions.ContactViewCommonData;
            })
            .catch(error => {
                this.error = error;
                this.permissions = undefined;
            });
    }

    handleMobileChange(event){
        this.mobile = event.target.value;
    }

    handleEmailChange(event){
        this.email = event.target.value;
    }

    handleHomePhoneChange(event){
        this.homePhone = event.target.value;
    }

    doEdit(){
        this.showModal = true;
    }

    doEditSave(){
        saveCitizenInSalesforce({ strCitizenId: this.recordId, strMobile: this.mobile, strEmail: this.email, strFijo: this.homePhone })
            .then(() => {
                this.doEditCancel();
            })
            .catch(error => {
                this.error = error;
            });
    }

    doEditCancel(){
        this.showModal = false;
    }

    doHiearchy(){

    }

    doSearchAddress(){
        let strUrl = '/global-search/' + encodeURIComponent(this.record.citizen.grouphash_coh__c);

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: strUrl
            }
        });
    }

    
}