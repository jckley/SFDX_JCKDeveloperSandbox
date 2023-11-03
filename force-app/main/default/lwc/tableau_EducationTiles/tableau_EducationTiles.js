import { LightningElement, api, track } from 'lwc';
import Resources from '@salesforce/resourceUrl/Communities';

export default class Tableau_EducationTiles extends LightningElement {
    iconEduPrimaria = Resources + '/SALESFORCE/img/Territories/ne_primario.svg';
    iconEduSecundaria = Resources + '/SALESFORCE/img/Territories/ne_secundario.svg';
    iconEduTerciaria = Resources + '/SALESFORCE/img/Territories/ne_universitario.svg';
    iconEduUniversitaria = Resources + '/SALESFORCE/img/Territories/ne_universitario_completo.svg';

    //workframe params
    @api set results(value) {
        if(!value) return;
        this._results = value;

        let tempArray = [];

        let educationFromAnalitycs = value;

        let primario = 0;
        let secundario = 0;
        let terciario = 0;
        let universitario = 0;

        educationFromAnalitycs.forEach(thisRow => {
            if (thisRow[this.labelColumnParam].toUpperCase().includes('PRIMARIO')) {
                primario += thisRow[this.valueColumnParam];
            }
            if (thisRow[this.labelColumnParam].toUpperCase().includes('SECUNDARIO')) {
                secundario += thisRow[this.valueColumnParam];
            }
            if (thisRow[this.labelColumnParam].toUpperCase().includes('TERCIARIO')) {
                terciario += thisRow[this.valueColumnParam];
            }
            if (thisRow[this.labelColumnParam].toUpperCase().includes('UNIVERSITARIO')) {
                universitario += thisRow[this.valueColumnParam];
            }
        })

        tempArray.push({ "name": "Primario completo", "image": this.iconEduPrimaria, "value": primario.toLocaleString(), 'filter':'Primario'});
        tempArray.push({ "name": "Secundario completo", "image": this.iconEduSecundaria, "value": secundario.toLocaleString(), 'filter':'Secundario'});
        tempArray.push({ "name": "Terciario completo / univ. incompleto", "image": this.iconEduTerciaria, "value": terciario.toLocaleString(), 'filter':'Terciario'});
        tempArray.push({ "name": "Universitario completo", "image": this.iconEduUniversitaria, "value": universitario.toLocaleString(), 'filter':'Universitario'});

        this.tileList = tempArray;
    }
    get results() {
        return this._results;
    }
    @api metadata;
    @api setSelection;
    @api selectMode;

    @api getState;
    @api setState;
    @api selection;


    //custom params
    @api valueColumnParam;
    @api labelColumnParam;
    filterFieldParam = 'Education_Level__c';


    @track tileList = [];

    handleClickTile(event) {
        if(!this.filterFieldParam) return;

        let tempState = {...this.getState()};

        for (let thisConfigItem of tempState.state.datasets.TerritoryFullPage_DS){
            if(thisConfigItem.fields[0] === this.filterFieldParam){
                thisConfigItem.filter.operator = 'matches';
                thisConfigItem.filter.values = event.currentTarget.getAttribute('data-filter');
            }
        }
        this.setState(tempState);
    }

}