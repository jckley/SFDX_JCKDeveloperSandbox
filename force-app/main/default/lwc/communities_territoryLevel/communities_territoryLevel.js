import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import retrieveChildTerritories from '@salesforce/apex/TerritoryListController.retrieveChildTerritories'
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import lblLevel from '@salesforce/label/c.AdministrativeLevel';
import lblTerritorySearch from '@salesforce/label/c.SearchTerritory';
import lblTerritoryView from '@salesforce/label/c.SeeTerritory';
import Resources from '@salesforce/resourceUrl/IconsPack1';
import { fireEvent } from 'c/pubsub';


export default class Communities_territoryLevel extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    iconSearch = Resources + '/searchps.svg';
    iconClose = Resources + '/closeemptyinputps.svg';
    iconRight = Resources + '/arrowrightps.svg';
    iconArrow = Resources + '/arrowps.svg';
    iconNivelAdm = Resources + '/niveladminsitrativops.svg';
    areDetailsVisible = false;
    showCard="display: block;";
    strLink = "";

    label = {
        lblLevel,
        lblTerritorySearch,
        lblTerritoryView
    };

    @api level;
    @track territories;

    // levelAnterior = level - 1;

    connectedCallback() {
        registerListener('territorySelected', this.handleTerritorySelected, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    handleClick(event) {
        let id = event.currentTarget.getAttribute("id");
        id = id.substring(0, id.length-3)
        fireEvent(this.pageRef, 'territorySelected', { 'parentid' : id , 'level' : (this.level + 1)} );
        console.log(id);
    }

    otrohandleClick(event) {
        let id = event.currentTarget.getAttribute("id");
        id = id.substring(0, id.length-3)
        console.log(id);
        // fireEvent(this.pageRef, 'territorySelected', { 'parentid' : id , 'level' : (this.level + 1)} );
    }

    territoryDetailLink(event){
        let id = event.currentTarget.getAttribute("territory-id");
        id = id.substring(0, id.length-3)

        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        var admTerritory = "territorio-administrativo/";
        var strNewURL = baseURL + "/s/" + admTerritory + id + "/view";
        this.strLink=strNewURL;

        fireEvent(this.pageRef, 'territorySelected', { 'strLink' : this.strLink });
        console.log('link: ' + strLink + ' id: '+ id);
        // return strNewURL;
    }

    handleTerritorySelected( {parentid, level } ) {
        // console.log("HandleTerritorySelected");
        // console.log("parentid: ", parentid);
        // console.log("level:", level);
        // console.log("this.level:", this.level);

        if(level === this.level) {
            retrieveChildTerritories({'strParentId' : parentid, 'intLevel' : level })
            .then(result => {
                this.territories = result;
                this.areDetailsVisible = true;
            }).catch(error => {
                this.areDetailsVisible = false;
            });
        } else if (level < this.level) {
            this.areDetailsVisible = false;
        }

        // hide card where previous level has no selected data
        if(level<(this.level-1)){
            this.showCard="display: none;";
        }else{
            this.showCard="display: block;";
        }

    }
}