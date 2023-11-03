import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class IFrameComponent extends LightningElement {
    @api src;
    @api title;
    @api width;
    @api height;

    iframeReady = false;
    stringToAppend;

    get srcToRender () {
        if(this.stringToAppend) {
            return this.src + '/' + this.stringToAppend;
        }
        return this.src;
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            let urlStateParameters = currentPageReference.state;
            let iframeparam = urlStateParameters.iframeparam;
            if (iframeparam) {
                let separateDashes = iframeparam.split('%2F');
                this.stringToAppend = separateDashes.join('/');
            }
            this.iframeReady = true;
        }
    }

}