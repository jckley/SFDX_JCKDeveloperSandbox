import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getProsumerAudienceCriterias from '@salesforce/apex/Prosumer_AudienciaPageController.getProsumerAudienceCriterias';
import { executeQuery, getDataset } from 'lightning/analyticsWaveApi';

import search from '@salesforce/resourceUrl/prosumerSearch';

const IS_LOG_ENABLED = true;
const DEFAULT_LOG = 'Prosumer, home: ';

function customLog(...stringsToLog) {
    const strArray = [DEFAULT_LOG];
    const completeLog = strArray.concat(stringsToLog);

    //cuando los logs estan activos por default, logeo y retorno null  
    if (IS_LOG_ENABLED) {
        console.log(...completeLog);
        return {forceLog:()=>null};
    }
    //cuando no, necesito una funcion para permitir loggear a manopla en algunos lugares    
    return {forceLog:()=>console.log(...completeLog)};
}

export default class Prosumer_Home extends NavigationMixin(LightningElement)  {
    search = search;

    cantidadCiudadanos;

    get formatedValues () {
        return {
            cantidadCiudadanos: this.cantidadCiudadanos ? this.cantidadCiudadanos.toLocaleString('es-AR') : '-'
        }
    }

    SAQLFilters;

    connectedCallback() {
        getProsumerAudienceCriterias()
        .then(response => {
            this.SAQLFilters = response?.SAQL ?? 'NOFILTERS';
        });
    }

    inputElement;
    handleInput(e){
        if(!this.inputElement){
            this.inputElement = this.template.querySelector('input');
        }
        if(e.keyCode === 13){
            this.navigateToSearchWith(this.inputElement.value)
        }
    }

    navigateToSearchWith (term) {
        this[NavigationMixin.Navigate]({
            type: 'standard__search',
            state: {
              term
            }
         });
    }

    data_set_id;
    param_data_set_version;

    get queryString() {
        customLog('queryString, getter');
        if (!this.data_set_id || !this.SAQLFilters) { return undefined; }

        let tempQuery = `q = load "${this.data_set_id}/${this.param_data_set_version}";`;

        if(this.SAQLFilters !== 'NOFILTERS') {
            tempQuery = tempQuery + `q = filter q by ${this.SAQLFilters};`
        }

        tempQuery = tempQuery + "q = group q by all;" +
                                    "q = foreach q generate count(q) as 'count';" +
                                    "q = limit q 2000;";

        return { query: tempQuery };
    }

    @wire(executeQuery, { query: '$queryString' })
    onExecuteQuery_byGender({ data, error }) {
        if (error) {
            customLog('query ERROR:', JSON.stringify(error)).forceLog();
        } else if (data) {
            customLog('query data:', JSON.stringify(data));
            this.cantidadCiudadanos = data.results.records[0].count;
        }
    }

    @wire(getDataset, { datasetIdOrApiName: 'TerritoryFullPage_DS' })
    onGetDataset({ data, error }) {
        if (error) {
            customLog('getDataSet error:', JSON.stringify(error)).forceLog();
        } else if (data) {
            customLog('getDataSet data:', JSON.stringify(data));
            this.data_set_id = data.id;
            this.param_data_set_version = data.currentVersionId;
        }
    }

}