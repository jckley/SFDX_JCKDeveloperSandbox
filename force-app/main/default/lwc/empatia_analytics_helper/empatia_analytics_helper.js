import { LightningElement, wire, api } from 'lwc';
import { executeQuery, getDataset } from 'lightning/analyticsWaveApi';

export default class Empatia_analytics_helper extends LightningElement {

    param_data_set;
    param_data_set_version;

    connectedCallback(){
        console.log('helper analytics');
    }

    get queryString () {
        if(!this.param_data_set) return undefined;

        let query = 
                `
                q = load "${this.param_data_set}/${this.param_data_set_version}";
                q = group q by all;
                q = foreach q generate count() as 'count';
                q = limit q 2000;
                `
        return { query };
    }

    @wire(getDataset, { datasetIdOrApiName: 'EmpatiaTerritory_DS' })
    onGetDataset({ data, error }) {
        console.log('datasetWire');
        if (error) {
            console.log('analyticsManagerTerritory getDataSet error:', JSON.stringify(error));
        } else if (data) {
            this.param_data_set = data.id;
            this.param_data_set_version = data.currentVersionId;
        }
    }

    @wire(executeQuery, { query: '$queryString' })
    onExecuteQuery({ data, error }) {
        console.log('queryWire');
        if (error) {
            const queryErrorEvent = new CustomEvent('queryerror', { detail: JSON.stringify(error) });
            this.dispatchEvent(queryErrorEvent);
        } else if (data) {
            console.log('analyitics helper despacha evento')
            const queryDataEvent = new CustomEvent('querydata', { detail: data });
            this.dispatchEvent(queryDataEvent);
        }
    }
}