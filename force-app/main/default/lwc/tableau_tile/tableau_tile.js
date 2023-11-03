import { LightningElement, api, track } from 'lwc';
import Resources from '@salesforce/resourceUrl/Communities';

export default class Tableau_tile extends LightningElement {
    //dejo de andar la reactividad de las propiedades sin el track...
    @api set imageRouteParam (value){
        this._imageRouteParam = value;
        this.tileImage = Resources + this.imageRouteParam;
    }
    get imageRouteParam () {
        return this._imageRouteParam;
    }
    @track tileImage;


    @api set results(value) {
        console.log('tile NOMBRE: ', this.tileLabel);
        console.log('setting Results: ', JSON.stringify(value));
        this._results = value;
        this.tileValue = value[0] ? value[0].count.toLocaleString() : 0;
    }
    get results() {
        return this._results;
    }
    @track tileValue;

    @api metadata;
    @api setSelection;
    @api selectMode;

    @api getState;
    @api setState;

    @api
    get selection() {
        return this._selection;
    }

    set selection(selection) {
        this._selection = selection;
    }

    @api measureColumn;
    @api labelColumn;

    @api
    get tileLabelParam () {
        return this._tileLabelParam;
    }
    set tileLabelParam (value) {
        this._tileLabelParam = value;
        this.tileLabel = value;
    }

    @track tileLabel;

    @api filterParam;
    @api filterFieldParam;
    handleClickTile (e) {
        let tempState = {...this.getState()};
        for (let thisConfigItem of tempState.state.datasets.Ciudadanos){
            if(thisConfigItem.fields[0] === this.filterFieldParam){
                thisConfigItem.filter.operator = 'matches';
                thisConfigItem.filter.values = [this.filterParam];
            }
        }
        this.setState(tempState);
    }

}