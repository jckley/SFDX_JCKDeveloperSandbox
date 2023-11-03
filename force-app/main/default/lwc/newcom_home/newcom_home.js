import { LightningElement,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import RESOURCES from '@salesforce/resourceUrl/Communities';
import { loadStyle } from 'lightning/platformResourceLoader';
import retrieveSite from '@salesforce/apex/CommunitiesController.retrieveSite';
import Search from '@salesforce/label/c.Search';
import CommunityHomeHeader from '@salesforce/label/c.CommunityHomeHeader';

export default class Communities_home extends NavigationMixin(LightningElement) {

    @track community_site;
    @track error;

    label = {
        CommunityHomeHeader,
        Search
    };

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

    doLoadStyles(){
        // loadStyle(this, RESOURCES + '/' + this.community_site + '/css/communities_home.css')
        //     /**
        //     .then(result => {
        //         // Possibly do something when load is complete.
        //     })
        //      */
        //     .catch(reason => {
        //         console.log('Error en carga de CSS:' + reason);
        //     });
    }
    
    doSearchCitizens(evt){

        console.log('doSearchCitizens()');

        const isEnterKey = evt.keyCode === 13;

        if (isEnterKey){
            this.searchTerm = evt.target.value;
            //console.log('this.searchTerm:' + this.searchTerm);
            let strUrl = '/global-search/' + encodeURIComponent(this.searchTerm);
            //console.log('strUrl:' + strUrl);
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: strUrl
                }
            })
            
        }
    }
    connectedCallback() {
        // document.querySelector(".search-bar-container").style.display = "none";
        // document.querySelector("#header-extension").style.display = "none";
        // document.querySelector("#parent-div-search-super-m").style.display = "none";
        document.querySelector(".search-bar-container").style.display = "";
        document.querySelector("#header-extension").style.display = "";
        document.querySelector("#parent-div-search-super-m").style.display = "";
    }
}