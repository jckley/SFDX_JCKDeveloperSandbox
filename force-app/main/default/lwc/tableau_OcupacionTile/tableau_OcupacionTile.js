import { LightningElement, api, track } from 'lwc';
import Resources from '@salesforce/resourceUrl/Communities';

export default class Tableau_OcupacionTile extends LightningElement {
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
            this._results = value;
            let tileValue = value[0] ? value[0].count : 0;
            this.tileValue = tileValue.toLocaleString()
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
    
        @api selection;
    
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
            console.log('Click')
            if(!this.filterParam || ! this.filterFieldParam) return
            
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