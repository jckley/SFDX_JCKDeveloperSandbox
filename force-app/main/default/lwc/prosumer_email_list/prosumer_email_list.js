import { LightningElement, } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getEmailList from '@salesforce/apex/prosumer_email_controller.getEmailList';

export default class Prosumer_email_list extends NavigationMixin(LightningElement) {

    _emailList;

    get emailList () {
        if(!this._emailList){
            return [];
        }

        const tempArray = this._emailList.map(thisEmail=>{
            return {
                ...thisEmail,
            }
            //                url: `/s/prosumer-email/email?emailid=${thisEmail.Id}`
        })

        return tempArray;
        
    }

    connectedCallback() {
        getEmailList()
            .then(response => {
                this._emailList = response;
            })
            .catch(error => {
                console.log('Paso algo en prosumer_email_controller: ', error);
            })
    }

    handleNuevoEmail() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'email__c'
            },
        });
    }

    handleNavigateToEmail(event){
        event.preventDefault()
        let emailId = event.currentTarget.dataset.emailid;
        console.log(emailId)
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'email__c'
            },
            state: {
                emailid: emailId
            }
        });
    }
}