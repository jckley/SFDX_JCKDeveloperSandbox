import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import retrieveChildTerritories from '@salesforce/apex/TerritoryListController.retrieveChildTerritories'
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import lblLevel from '@salesforce/label/c.AdministrativeLevel';
import lblTerritorySearch from '@salesforce/label/c.SearchTerritory';
import lblTerritoryView from '@salesforce/label/c.SeeTerritory';
import Resources from '@salesforce/resourceUrl/major';
import { fireEvent } from 'c/pubsub';


import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import retrieveRootTerritory from '@salesforce/apex/TerritoryListController.retrieveRootTerritory'
import lblTerritory from '@salesforce/label/c.Territory';



export default class NewCom_territoryLevel extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    iconSearch = Resources + '/img/Territories/iconsearch.svg';
    iconClose = Resources + '/img/Territories/closetab.svg';
    iconRight = Resources + '/img/Territories/arrowrightps.svg';
    iconArrow = Resources + '/img/Territories/arrowps.svg';
    iconNivelAdm = Resources + '/img/Territories/niveladminsitrativops.svg';
    showCard="display: block;";

    label = {
        lblLevel,
        lblTerritorySearch,
        lblTerritoryView
    };

    @api level = 0;
    @track territories;
    @api rootTerritoryId;
    @track territoryboxes = [];
    @track strLink = "";
    @track viewButton = "slds-hide";

    connectedCallback() {
        console.log("connectedCallback");
    }

    disconnectedCallback() {
    }

    handleClick(event) {
        console.log(event.currentTarget.id);
        let id = event.currentTarget.id;
        let territory = event.currentTarget.dataset.name;

        id = id.substring(0, id.length-2)

        let urlString = window.location.href;
        let baseURL = urlString.substring(0, urlString.indexOf("/s"));
        let strNewURL = baseURL + "/s/territorio-administrativo/" + id + "/view";
        this.strLink = strNewURL;

        this.territoryboxes[this.level-1].id = id;
        this.territoryboxes[this.level-1].name = territory;
        this.territoryboxes[this.level-1].class = "territorybox selected slds-col slds-size_1-of-1 slds-large-size_1-of-4";
        this.territoryboxes[this.level-1].href = strNewURL;

        // this.setViewButton();

        this.handleTerritorySelected(id, parseInt(this.level) + 1);
    }

    setViewButton(){
        if(this.territories.length==0){
            this.viewButton = 'territoryboss';
        } else {
            this.viewButton = "slds-hide"
        }
    }

    goLastTerritory(){
        const largo = this.territoryboxes.length;
        const href = this.territoryboxes[largo-1].href;
        // console.log(href);
        window.location.replace(href);
    }

    handleTerritoryBoxCloseClick(event) {
        console.log("handleTerritoryCloseBoxClicked");
        let territory = event.currentTarget.closest(".territory-name");
        this.hideTerritorySearchBox(territory.dataset.level);
        this.handleTerritorySelected(territory.dataset.parentid, territory.dataset.level);
    }


    // territoryDetailLink(event){
    //     let id = event.currentTarget.getAttribute("territory-id");
    //     id = id.substring(0, id.length-3)

    //     var urlString = window.location.href;
    //     var baseURL = urlString.substring(0, urlString.indexOf("/s"));
    //     var admTerritory = "territorio-administrativo/";
    //     var strNewURL = baseURL + "/s/" + admTerritory + id + "/view";
    //     this.strLink=strNewURL;

    //     fireEvent(this.pageRef, 'territorySelected', { 'strLink' : this.strLink });
    //     console.log('link: ' + strLink + ' id: '+ id);
    // }

    handleInputFilter(e) {
        this.territories.forEach(t => {
            t.visible = t.Name.toLowerCase().includes(e.currentTarget.value.toLowerCase());
        });
    }

    showTerritorySearchBox(parentid, level) {
        this.territoryboxes.push({parentid: parentid, id: "", level: level, name: "", class: "territorybox slds-col slds-size_1-of-1 slds-large-size_1-of-4", href: ""});
    }

    hideTerritorySearchBox(level) {
        while (this.territoryboxes.pop().level > level);
    }

    handleTerritorySelected(parentid, level) {
        // console.log("HandleTerritorySelected2");
        // console.log("parentid: ", parentid);
        // console.log("level:", level);
        // console.log("this.level:", this.level);
        // console.log("type Id = ", typeof parentid);

        this.showTerritorySearchBox(parentid, level);

        retrieveChildTerritories({'strParentId' : parentid, 'intLevel' : level })
        .then(data => {
            console.log(data);
            this.territories = [];
            data.forEach(d => {
                this.territories.push({Id: d.Id, Level: d.Level, Name: d.Name, visible: true});
            });
            // console.log("--------------------------");
            // console.log(this.territories);
            // console.log(this.territories.length);
            if (this.territories.length == 0) {
                // console.log("It's empty!!!");
                this.territoryboxes.pop();
            }
            // console.log("--------------------------");
            this.level = level;
            this.setViewButton();
        }).catch(error => {
            console.log(error);
        });
    }


    @wire(retrieveRootTerritory)
    wiredRetrieveRootTerritory(objResult) {
        if(objResult !== undefined && objResult !== null && objResult.data !== undefined && objResult.data !== null) {
            console.log("wiredRetriveRootTerritory!!!!!!");
            console.log(`objResult.data.Id: ${objResult.data.Id}`);
            console.log(`objResult.data.Level: ${objResult.data.Level}`);
            this.rootTerritoryId = objResult.data.Id;
            this.handleTerritorySelected(objResult.data.Id , parseInt(objResult.data.Level) + 1);
        }
    }

    renderedCallback() {
        console.log("renderedCallback");
        // Promise.all([
        //     loadScript(this, 'https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js'),
        //     loadStyle(this, 'https://fonts.googleapis.com/icon?family=Material+Icons'),
        //     loadStyle(this, 'https://fonts.googleapis.com/css?family=Roboto:regular,bold,medium'),
        // ]);
   }

}