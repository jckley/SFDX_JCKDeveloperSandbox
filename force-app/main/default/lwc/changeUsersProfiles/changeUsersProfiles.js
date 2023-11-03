import { LightningElement,api,track,wire } from 'lwc';
import retrieveUsers from '@salesforce/apex/UserProfileController.retrieveUsers';
import retrieveProfiles from '@salesforce/apex/UserProfileController.retrieveProfiles';

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'ProfileId', fieldName: 'ProfileId'},
    { label: 'Profile', fieldName: 'Profile.Name'},
    { label: 'Active', fieldName: 'IsActive', type: 'boolean' },
];

export default class ChangeUsersProfiles extends LightningElement {

    columns = columns;
    @track users = [];
    @track profiles = [];
    @track error;
    
    async connectedCallback() {
        console.log('ChangeUsersProfiles In connectedCallback()...');

        retrieveUsers()
            .then(result => {
                console.log('result[0]: ' + JSON.stringify(result[0]));
                this.users = result;
                this.error = undefined;
            })
            .catch(error => {
                this.users = undefined;
                this.error = error;
            });
        
        retrieveProfiles()
            .then(result => {
                this.profiles = result;
                this.error = undefined;
            })
            .catch(error => {
                this.profiles = undefined;
                this.error = error;
            });
    }

}