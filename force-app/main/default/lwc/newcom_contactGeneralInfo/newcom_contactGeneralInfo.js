import { LightningElement,api,track,wire } from 'lwc';
import RESOURCES from '@salesforce/resourceUrl/Communities';
import { loadStyle } from 'lightning/platformResourceLoader';
import retrieveSite from '@salesforce/apex/CommunitiesController.retrieveSite';
import retrieveInfoFromCitizenId from '@salesforce/apex/CommunitiesController.retrieveInfoFromCitizenId';
import retrieveLoggedUserPermissions from '@salesforce/apex/ContactDetailController.retrieveLoggedUserPermissions';
import Names from '@salesforce/label/c.Names';
import LastNames from '@salesforce/label/c.LastNames';
import ID from '@salesforce/label/c.ID';
import Nationality from '@salesforce/label/c.Nationality';
import Gender from '@salesforce/label/c.Gender';
import Birthday from '@salesforce/label/c.Birthday';
import Age from '@salesforce/label/c.Age';
import CUIT_CUIL from '@salesforce/label/c.CUIT_CUIL';

export default class Newcom_ContactGeneralInfo extends LightningElement {

    @api recordId;
    @track record;
    @track community_site;
    @track error;
    @track iconProfile;
    @track contactNames;
    @track lastNames;
    @track dni;
    @track nationality;
    @track gender;
    @track birthday;
    @track age;
    @track cuil;
    @track photoLegacyUrl;
    @track viewContactTags;

    label = {
        Names,
        LastNames,
        ID,
        Nationality,
        Gender,
        Birthday,
        Age,
        CUIT_CUIL
    };

    @wire(retrieveInfoFromCitizenId, { contactId: '$recordId' })
    wiredContact({ error, data }) {
        if (data) {
            //console.log(JSON.stringify(data));
            this.record = data;
            this.error = undefined;
            this.doLoadContactData();
            this.doLoadPermissions();
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

    connectedCallback() {        
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
    }


    doLoadStyles(){
        // loadStyle(this, RESOURCES + '/' + this.community_site + '/css/communities_contactGeneralInfo.css')
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
        this.contactNames = this.record.citizen.FirstName + ' ' + (this.record.citizen.MiddleName != null && this.record.citizen.MiddleName != 'undefined' ? this.record.citizen.MiddleName : '');
        this.lastNames = this.record.citizen.LastName;
        this.dni = this.record.generalInfo.DNI;
        this.nationality = this.record.citizen.Nacionalidad__c;
        this.gender = this.record.generalInfo.Gender;
        this.birthday = this.record.generalInfo.BirthdateSPFormat;
        this.age = this.record.citizen.Age_f_x__c;
        this.cuil = this.record.generalInfo.CUIT;
        this.photoLegacyUrl = this.record.citizen.PhotoUrl_legacy__c;
        if(this.photoLegacyUrl===undefined || this.photoLegacyUrl===''){
            if(this.gender == 'Mujer'){
                this.photoLegacyUrl = RESOURCES + '/SALESFORCE/img/avatar-w.svg';
            }else{
                this.photoLegacyUrl = RESOURCES + '/SALESFORCE/img/avatar-m.svg';
            }
            // console.log('gender: ' + this.gender);
            // console.log('photo: ' + this.photoLegacyUrl);
        }
        
    }

    doLoadPermissions(){
        if(this.permissions.ContactViewTags == undefined){
            this.viewContactTags = true;
        } else
        this.viewContactTags = this.permissions.ContactViewTags;
        // console.log("permiso contact tags: " + this.viewContactTags);
    }
}