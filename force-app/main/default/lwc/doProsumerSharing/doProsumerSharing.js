import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class DoProsumerSharing extends LightningElement {
    //Debouncing
    isExecuting = false;
    timeTillButtonOnlineAgain = 2000;

    @api recordId;
    
    @api invoke() {
        if(this.isExecuting) return;
        this.isExecuting = true;

        console.log('VERIFICO DEBOUNCE')
        let event = new ShowToastEvent({
            title: 'I am a headless action!',
            message: 'Hi here: ' + this.recordId,
        });
        this.dispatchEvent(event);

        window.setTimeout(()=>{this.isExecuting = false}, this.timeTillButtonOnlineAgain);
      }
}